import csv
import os.path
import sys

all_projects = set()

# project_to_deps['project_abc']['io.micrometer:micrometer-core'] -> 1.6.5 (*)
# {   'a': {'depA': '5.4.5', 'depX': '0.0.1'},
#     'b': {'depA': '5.4.5'},
#     'c': {'depC': '1.0'}
# }
project_to_deps = {}

types_dep_to_project = {
    # 'java': {
    #     'depA': {
    #         'projectA': '1.20',
    #         'projectB': '0.1',
    #     }
    # },
    # 'terraform': {
    #     'depA': {
    #         'projectA': '1.20',
    #         'projectB': '0.1',
    #     ]
    # }
}

# {   'java': {   'com.google.cloud:spring-cloud-gcp-starter-data-datastore',
#                 'com.google.cloud:spring-cloud-gcp-starter-logging',
#                 'com.google.cloud:spring-cloud-gcp-starter-metrics',
#     },
#    'terraform': {   'registry.terraform.io/hashicorp/archive',
#                      'terraform'}
# }
all_types_to_deps = {}


def add_dependencies_for_type(version_type, versions_csv):
    with open(versions_csv, newline='') as csvfile:
        reader = csv.reader(csvfile, delimiter=';')
        for row in reader:
            project, dep, dep_version = (row[0], row[1], row[2])

            # keep track of all projects
            all_projects.add(project)

            # store deps for types (e.g. java, terraform)
            if version_type not in all_types_to_deps:
                all_types_to_deps[version_type] = set()
            all_types_to_deps[version_type].add(dep)

            # store deps for each projects
            if project not in project_to_deps:
                project_to_deps[project] = {}
            project_to_deps[project][dep] = dep_version

            if version_type not in types_dep_to_project:
                types_dep_to_project[version_type] = {}
            if dep not in types_dep_to_project[version_type]:
                types_dep_to_project[version_type][dep] = {}
            types_dep_to_project[version_type][dep][project] = dep_version
    # pp = pprint.PrettyPrinter(indent=4)
    # pp.pprint(project_to_deps)
    #
    # pp = pprint.PrettyPrinter(indent=4)
    # pp.pprint(all_types_to_deps)


def generate_result_table():
    # start table
    result_html = "<table class=\"styled-table\">\n"

    # header row
    result_html += "    <tr>\n"
    result_html += "        <th>&nbsp;</th>"
    for project in sorted(all_projects):
        result_html += "<th>" + project + "</th>"
    result_html += "        <th>&nbsp;</th>"
    result_html += "\n    <tr>\n"

    result_html = append_rows_by_version_type(result_html, 'java')
    result_html = append_rows_by_version_type(result_html, 'terraform')

    # end table
    result_html += "</table>\n"
    return result_html


def append_rows_by_version_type(result_html, version_type):
    result_html += "    <tr>\n"
    version_type_subheader = "<td align=\"center\"><b>" + version_type.capitalize() + "</b></td>"
    result_html += version_type_subheader
    result_html += "        <td colspan=" + str(len(all_projects)) + "></td>"
    result_html += version_type_subheader
    result_html += "\n    <tr>\n"
    # check if we have collected data
    if version_type not in all_types_to_deps:
        print("no results found for %s" % version_type)
        return result_html
    # dependency rows
    for dep in sorted(all_types_to_deps[version_type]):
        result_html += "    <tr>\n"
        result_html += "        <td nowrap>" + dep + "</td>"
        for project in sorted(all_projects):
            if project in types_dep_to_project[version_type][dep]:
                dep_version = types_dep_to_project[version_type][dep][project]
                result_html += '<td title="%s -> %s:%s">%s</td>' % (project, dep, dep_version, dep_version)
            else:
                result_html += "<td>&nbsp;</td>"
        result_html += "        <td>" + dep + "</td>"
        result_html += "\n    </tr>\n"
    return result_html


def build_model():
    dep_version_to_type = {
        'gradle': 'java',
        'maven': 'java',
        'terraform': 'terraform',
    }
    for dep_version in dep_version_to_type:
        if os.path.isfile('{}/{}_versions.csv'.format(version_csv_dir, dep_version)):
            print('Analyzing [{}/{}_versions.csv]'.format(version_csv_dir, dep_version))
            add_dependencies_for_type(dep_version_to_type[dep_version],
                                      '%s/%s_versions.csv' % (version_csv_dir, dep_version))
        else:
            print('Skipping [{}/{}_versions.csv] as not present'.format(version_csv_dir, dep_version))


report_html_filename = "report.html"

version_csv_dir = "/home/msauer/dependency_report/results/" #sys.argv[1]  # 1st arg
report_result_dir = "/home/msauer/dependency_report/report" # sys.argv[2]  # 2nd arg

print("using result cvs from directory: %s" % version_csv_dir)
print("using report directory: %s" % report_result_dir)

build_model()
result_table = generate_result_table()
print("\n*** generated report to {0}/{1} ***\n".format(report_result_dir, report_html_filename))

with open("report_template.html", "rt") as fin:
    with open(report_result_dir + "/" + report_html_filename, "wt") as fout:
        for line in fin:
            fout.write(line.replace('%result_table%', result_table))
