cd repo
gh issue list -L 1000| tr '\t' ';' > ../data/fa_issues.csv
# The milestone is not included in the returned issues. So this requires a separate query.
gh issue list -m "7.0" -L 1000 | tr '\t' ';' > ../data/fa_milestone_issues.csv