# fluentassertions-analysis
This repo is a public analysis of the .net [Fluent Assertions](https://github.com/fluentassertionsfluentassertions) library. The goal with this public analysis is personally to learn the tools and better understand and teach patterns and anti-patterns. On the other hand this is a means to to provide valuable insights for open source projects and help them evolve as well.

## Context
**GitHub Project:** [Fluent Assertions](https://github.com/fluentassertionsfluentassertions)  
**Website/Docs:** https://www.fluentassertions.com  
**Tools used:**  
* [CodeScene](https://codescene.io/projects/47340/jobs/1860887/results?scope=month#code-health)
* [NDepend](https://www.ndepend.com/)
  * [Report](data/ndepend/NDependOut/NDependReport.html)

# Setup
This analysis aims and assessing quality of a codebase and identify hotspots that have impact on a publicly available roadmap. The aim is to answer the following questions:

## Questions
1. What parts of the code is work being planned/expected on?
    1. The short term? i.e. a next release.
    2. The longer term.
    3. What are the constraints for these changes?
2. Where are the hotspots and which are expected to be impacts by planned work?
3. What strategies can be advised to reduce the identified hotspots that aligns with work planned?
4. What other conclusions, advice and general lessons can be extracted from this analysis?

## Results
Data from various tools can be found in the `data` folder. Written analysis and a final report/article is places in the `docs` folder.

* Question 1 is answered in the the [change forecast](docs/changes_forecast.md).
* Question 2 is divided amongst an analysis using [CodeScene](docs/hotspots_codescene.md) and [NDepend](docs/hotspots_ndepend.md)
* Question 3 is partially answered in both of the analysis but is a much more extensive effort for certain issues identified and possible better addressed using actual PR's.
* Question 4 is a TODO for a more final overview.


