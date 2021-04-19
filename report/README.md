# Usage

_very_ quick and dirty approach for rendering the csv files as report table, ugly as hell ... i
know :)

- expects the type*_versions.csv files to be ready and in a certain format
  - see ./test/files for examples
- expects the output directory for the report to exist and be writable

e.g.

```bash
# build venv
make venv
# active venv
source venv/bin/activate
# execute report generation
# python3 report.py path_to_csv_files path_to_report_dir (must exist)
# e.g.
python3 report.py ./test/files ${HOME}/dependency_report/report
```
