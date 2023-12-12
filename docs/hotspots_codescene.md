# CodeScene Hotspots
For a first analysis and also learning CodeScene I'm using the hotspots as a starting point.

## Code Health hotspots
So the code health is one of the aspects of calculating refactoring Targets. Hotspots in the codebase and they are based on Code Health score. This is an aggregated score based on violations and warnings of certain rules. This is similar to what NDepend does, and it goes somewhat deep to discuss all the rules here. The full documentation can be found [here](https://codescene.io/docs/guides/technical/code-health.html?highlight=code+health).

> Code Health is an aggregated metric based on 25+ factors scanned from the source code. 

It is composed of:
* Module level issues
* Function level issues
* Implementation level issues

### Hotspots
I don't understand why the tool doesn't provide a simple export button. But fortunately the dev tools provided the API endpoint that outputs what is called `biomarkers.csv` which contains the Hotspot Code Health data.

It's easy to see a pattern here, especially if we leave out the tests. 7 our of 12 files (58%) of the refactoring targets are classes that end with `Assertions.cs`. And they take the top 6 of the list.

_What I don't understand here is the fact that I only get 17 files. I was wondering if that has to do with the last month since it also contains file with a code health of 10._

## Refactoring Targets
These are identified using an algorithm that not only takes into account the Code Health but also the change frequency but also other aspects such as change coupling and amount of devs making changes making it a potential coordination bottleneck.

### Priority Targets
* [GenericCollectionAssertions.cs](https://codescene.io/projects/47340/jobs/1860887/results/code/hotspots/biomarkers?name=fluentassertions%2FSrc%2FFluentAssertions%2FCollections%2FGenericCollectionAssertions.cs) (5)
* CollectionSpecs.cs (5)

### Targets
* [GenericDictionaryAssertions.cs](https://codescene.io/projects/47340/jobs/1860887/results/code/hotspots/biomarkers?name=fluentassertions%2FSrc%2FFluentAssertions%2FCollections%2FGenericDictionaryAssertions.cs) (7)
* [TypeAssertions.cs](https://codescene.io/projects/47340/jobs/1860887/results/code/hotspots/biomarkers?name=fluentassertions%2FSrc%2FFluentAssertions%2FTypes%2FTypeAssertions.cs) (5)
* [AssertionExtensions.cs](https://codescene.io/projects/47340/jobs/1860887/results/code/hotspots/biomarkers?name=fluentassertions%2FSrc%2FFluentAssertions%2FAssertionExtensions.cs) (8)
* [Src/Primitives/StringAssertions.cs](https://codescene.io/projects/47340/jobs/1860887/results/code/hotspots/biomarkers?name=fluentassertions%2FSrc%2FFluentAssertions%2FPrimitives%2FStringAssertions.cs) (6)
* [Src/Primitives/DateTimeOffsetAssertions.cs](https://codescene.io/projects/47340/jobs/1860887/results/code/hotspots/biomarkers?name=fluentassertions%2FSrc%2FFluentAssertions%2FPrimitives%2FDateTimeOffsetAssertions.cs) (7)

TypeAssertions is an example that more than just the Code Health score determines (the priority of) a refactoring target.

# Analysis
The pattern in this data is clear, it's mostly `Assertions` classes that are identified as problematic. The name also clearly indicated these are a rather fundamental part of the application.

The overall pattern in most of these classes is that they violate rules regarding _(Potentially) Low Cohesion_, _Deep, Nested Complexity_ or _Bumpty Road_. The latter two I would categorize as complexity.

## Violations

### Cohesion
> CodeScene measures cohesion using the LCOM4 metric (Lack of Cohesion Measure). With LCOM4, the functions inside a module are related if a) they access the same data members, or b) they call each other. 

Now from the standpoint of A) the `Assertions` are quite cohesive, most of them access the only piece of instance data, the `Subject`. However, many of the methods indeed do not call each other unless it's convencience overloads.
There is however a good reason for this, the `Assertions` classes are an essentially what make them `Fluent`. Each static `Should` extension method returns an instance of a type/context specific assertion class that provides all 
the possible means to Assert that object. The amount of functions is thus determined by the amount of different assertion that can be done on a specific type.

### Complexity / Bumps
This is a less common violation since it's not influenced by a fundamental aspect of the design. It is a function level metric and the hotspots are thus also in specific functions. Given they're both related to complexity there is 
overlap but not necessarily. Code with high complexity can still contain a single bump.

## Warnings
Are as the name suggest considered less of a problem for the code health but can indicate maintainability issues. But not all warnings are created equal. Some might be very well explained by library purpose or deliberate design decisions.

### Duplication - the biggest common denominator
There is a large degree of duplication visible in these hotspots. Sometimes involving about half of the functions for instance for `TypeAssertions`. I would find it a lot easier to assess if a percentage of duplication is given for a class.
It only lists only duplicatin functions within the class. 

* _It's not clear weather it's not measured or not found across classes._
* _It looks like a deliberate design decision to be able to fully read how an assertion works which wouldn't be possible if hidden inside another abstraction._

### Primitive obsession
A large part of the api exposes the means to provide reasons with potential formatting parameters. There are strings and object arrays. For another part the library is built to assert values of primitives. So it should come as a surprise for 
certain `Assertions` classes.

