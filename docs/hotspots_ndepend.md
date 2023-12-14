# NDepend Hotspots

NDepend uses a similar approach as CodeScene of rules that result in certain error levels. Main difference is that it:

- Doesn't take into account git data.
  - It does have time based trends, but that is based on the individual runs of the analysis and not on commits.
- Has a much faster ruleset
- Allows for writing your own rules

## Rules, Issues and Quality Gates

To understand the reported numbers some explanation is required about the rules and their output. The basis as mentioned
above are rules. Rules are written in Code Query Language which an NDepends DSL based on LINQ. Rules are stacked, i.e.
there are `Quality Gate` rules that count the result of `Issue` rules. But there are also rules, or maybe just queries
that assist in the analysis for refactoring purposed.

An ` Issue` rule is one that is defined to trigger a violation warning if the result of the query is not empty using a
specific `warnif`start statement. There's an added distinction which is that rules can be defined as`Critical`. These
are by default used in a `Quality Gate`rule that fails if there a`Critical` rule violations.

## Debt and interest

All the `Issue` rules return a [Debt](https://www.ndepend.com/docs/technical-debt) value (which is the estimated time to
fix the issue) and the accrued yearly [interest](https://www.ndepend.com/docs/technical-debt#Severity) Depending on the
amount of debt a Severity is determined using threshold levels. It is possible to fine-tune Debt calculation and
thresholds but that's beyond the scope of this analysis so we'll use the defaults.

_Now they cleary state the values are estimates. It's not clear however if for instance certain estimates are based on
research._ _They refer to the SQALE method which is then used to implement
[debt ratio & rating](https://www.ndepend.com/docs/technical-debt#DebtRating)_ _I'm trying to calculate the ration
myself but the explanation is simply not clear to me!_

## Types to fix

NDepend has it's `Types to fix` query. The hotspots query selects any class that it considers contains technical debt
and accrues interest. The types to fixes only shows those types that have a debt value of more than 30 minutes and is
ordered by the breaking point. The [breaking point](https://www.ndepend.com/docs/technical-debt#BreakingPoint) is: _the
debt divided by the annual-interest._ So if the cost of fixing it is low while the cost of leaving it is high, the
breaking point is lower and paying off the debt is considered most valuable here.

However, the debt on a type level is the aggregate value of the debt & interest of all issues. The interest on more
severe issues is higher with the idea that there is often a higher return on investment. Which however depends on the
Debt ofcourse, but let's for now assume that's the case. So instead of just looking at the types to fix it makes more
sense to use the severity as a driver for selecting potential refactoring targets.

_This is a list of 44 types order by interest. Each with few or many issues. Determining a subset here could by done
by:_

- Filtering types on a initial area assessment.
- Don't use this and start with the critical issues first.

## Issue Severity Targets

There are no Blocker issues which NDepend defines as _cannot move to production_. The next level is critical, which
_should not move to production_.

### Critical issues

There is only rule that results in critical severity that triggers: `Avoid types initialization cycles`. This rule
related to **static** type initialization and more is explained in
[this article](https://codeblog.jonskeet.uk/2012/04/07/type-initializer-circular-dependencies/) where the rule points
to.

The types reported are:

- `AssertionOptions`
- `GenericDictionaryEquivalencyStep`
- `GenericEnumerableEquivalencyStep`

It is the `AssertionOptions` static type initialization that is intertwined with the static type initializers of the
`EquivalencySteps`

## Critical rule targets

As mentioned there is a set of rules that are considered critical. Now these rules can return results with varying
severity because each returned code element can contain varying levels of `Annual Interest`. There are 5 critial rules
violated. Let's look at them individually

### ND1000: Avoid types too big (1)

The types too big returns the NumericAssertionsExtensions. It has a health score of 6 in CodeScene although it's not
part of the limited list. Given it's merely static extension method it would not be difficult to split up.

### ND1003: Avoid methods too big, too complex (1)

This identifies the XmlValidator.Validate() method as being too complex with a Cyclomatic Complexity score of 22. This
is also reported in CodeScene with a health 8 and this method indeed as being too complex.

### ND1400: Avoid namespaces mutually dependent (210)

The amount of mutual dependencies is obviously the most striking violation. This deserves a further analysis chapter in
itself. But it's already obvious that a refactoring here implies moving code and thus cause breaking changes since those
classes are part of the public interface.

### ND1901: Avoid non-readonly static fields (4)

One of the reported classes here is `AssertionOptions` which is also involved in the Critical issues. One of the other
classes reported: `FluentAssertions.Common.Services` is called from this `AssertionOptions` class. The `Services` class
is also mentioned in issue
[#2291 Combine Configuration, Services and AssertionOptions](https://github.com/fluentassertions/fluentassertions/issues/2291)
so it makes sense to identify this as a refactoring target.

### ND2012: Avoid having different types with same name (1)

These are two classes named Node where one (`FluentAssertions.Xml.Equivalency.Node`) is internal and essentially an
`XmlNode`. Simply rename would resolve this.

# Mutual namespace dependencies

Before doing a further analysis of this rule let's reason a bit about it's usability. The rule says low level namespaces
should not depend on high level namespaces. I was initially suspecting that such implies that FluentAssertions is
considered the lowest level namespace and FluentAssertions.Primitive is then a higher level namespace. However it is
calculated in a different way, lowest level namespaces are those of a pair that have highest Afferent Coupling within a
mutually dependent pair. This is sometimes also referred to as Fan In coupling. So if there's a pair such as named above
with given coupling cardinality `FluentAssertions 2 <-> 10 FluentAssertions.Primitives` then the Primitives namespace
would be considered the low level namespace.

Although it being a critical rule, far from all issues returned have a high severity, only 18 out of 223 issues have a
higher severity and should thus have a higher ROI for fixing.

## The nature of the Fluent API

The Fluent API is essentially enable by extension methods on types named `Should()`. Now all these extension methods
reside in `AssertionExtension` classes in the root namespace and call into the sub namespaces. These are simple static
methods that instantiate type specific `Assertions` classes that enable the further fluency of the API. Although it's
fairly easy to move each set of `Should` methods into the namespaces of the Assertions they instantiate. It breaks all
`using` statements of the millions of consumers.

The same applies for many other static extension method classes that are glue between types & assertions. Splitting
up these static interfaces would hurt discoverability of the Fluent API. Moving complete type could help reducing some
of the mutuality.

## Compile time 'service' collections 

Part of the mutual dependencies is caused by compile time binding of interface implementations. Specifically the 
EquivalencySteps & the Formatters. In many scenario's this is done runtime using IoC containers and assembly scanning.
Here the `Formatter` and `EquivalencySteps` types are grouped together in a single namespaces. There are just some slight
deviations where either an implementation is not in the same namespace (`XmlNodeFormatter`) or the container collection 
is not in the same namespace (`EquivalencyPlan`).

## Non public members

Filtering out all mutual dependencies where either the caller of callee is public two classes remain:

* `Services`
* `SelfReferenceEquivalencyOptions`

Both of these classes are also in the top 10 of the types to fix. So it's worth researching what can be resolved there.

## Options
There are two `Options` suffixed classes that are in the top 10 of types to fix query. Given that the Options architecture
is also under scrutiny and that change has already been classified as breaking fixing the problems identified.
