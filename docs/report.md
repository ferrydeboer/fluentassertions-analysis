Currently this serves as a braindump of some ideas I might/want to address in a final article/report.

- Time based analysis. Both have it. NDepend also has rules that give priority to newer introduced problems.
  - Ideally I might want to write some tooling that can maybe run repeated retrospective analysis to compose a timeline
    retroactively.

# Conclusion

The amount of information coming from CodeScene and NDepend is a huge. The fact that we're dealing with a popular
library is a complicating factor when it come to rafactor candidate selection. Given I'm new to some of the tooling I
decided to propose actual solutions in a second part or maybe even draft PR's. So based on the results from both tools I
divided the hotspots in Now, Next, Later and Never.

## Now

### Core changes

It's NDepend that is pointing out some stuctural issues that really do coincide with changes in the Core. Especially the
desired combination of `Configuration`, `Services` & `AssertionOptions`. Of which the latter two are in the top 10 of
types to fix. It could be optional to look at the NDepend issue that might relate to desired changes in `AssertScope`.
However the ROI on that Debt is listed lower.

### Equivalency

There's 2 issues listed under 7.0 that relate to the equivalency area. And a critical issue is identified in NDepend.
Suspectedly it hasn't lead to real problems in production yet but it is coupled with the `AssertionOptions` issue.

The Equivalency namespace also contains a substantial amount of types to fix which amongts others have Mutual Dependent
Namespaces issues. Given these are not Assertions of Extensions classes these can be researched.

_Requires more research!_

## Next

### Collection Assertions Complexity

This leaves out large parts of Hotspot Code Health issues identified by CodeScene. What is left standing in those
identified hotspots is the Complexity and Duplication problems in both the `CollectionAssertions`. Given that there are
issues on the backlog in the `Collections` area of the codebase. Improving those quality attributes there could be
beneficial. However, it would require more in depth knowledge and research to understand if this is possibly
overlapping.

## Later

There are many more NDepend issues that could use attention. But those are lower priority. They could be put up for
grabs. But that is much more valuable when tools are integrated in the development process and have appropriate
adjustments to filter out the noise or what the team considers false positives.

## Probably Never

There's a substantial amount of technical debt that is the direct effect of the (static) nature of the Fluent API. This
mostly causing problems being reported regarding:

- Low Cohesion & Lacking Modularity
- Primitive Obsession
- Mutual Dependencies

These are essentially classes that are suffixed `Assertions` and `Extensions`. Splitting up these classes hurts
discoverability of the API. There is maybe some potential to resolve this for the `Assertions` using another layer of
extension methods but that requires some research and adds no direct benefit to the issues at hand.

## Part 2 - How to refactor

The idea was to actually provide possible solutions to higher priority issues. But given I was drowning in the amount of
information I decided to leave that for a part 2. Also, actual PR's are probably more valuable than just writing about it.


### Part 3 - Tool comparison

- Their Avoid Types with poor cohesion returns no result. This probabably has to do with different calculation and
  NDepend LCOM looks at fragmentation between use of class variables and not the extent to which functions either rely
  on each other or the class field.
