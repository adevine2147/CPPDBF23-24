import os
import re
from github import Github

repository_name = 'adevine2147/CPPDBF23-24'

# Define the GitHub token secret name
# Get the GitHub PAT from the environment variable
github_token = os.getenv("GH_PAT")

# Create a GitHub API client using the token
g = Github(github_token)

# Initialize the GitHub API client with the token
repo = g.get_repo(repository_name)

# Define the folder containing weekly update markdown files
folder_path = 'systems/updates'

contents = repo.get_contents(folder_path, ref="main")

# Iterate through the contents to find directories
directories = [content for content in contents if content.type == 'dir']

# Initialize a dictionary to store summaries by week number
summaries_by_week = {}

# Initialize a variable to store the combined summary for the main readme
combined_main_readme_summary = ""
latest_week_number = 0  # Initialize with a default value
latest_week_summary = ""  # Initialize with an empty string

# Initialize a dictionary to store subteam budgets
subteam_budgets = {
    "Aerodynamics Team": 800,
    "Structures Team (Wed)": 2500,
    "Structures Team (Fri)": 2500,
    "Payload Team": 1000,
    "Systems Team": 200,
}

# Initialize a dictionary to store subteam spendings
subteam_spendings = {}

for directory in directories:
    # List all markdown files in the subdirectory
    files = repo.get_contents(directory.path, ref="main")
    markdown_files = [file for file in files if file.name.endswith(".md")]

    # Determine the week number from the directory name
    week_match = re.match(r'^week(\d+)$', directory.name)
    if week_match:
        week_number = int(week_match.group(1))
        
        # Initialize a list to store summaries for this week
        week_summaries = []

        # Initialize a dictionary to store costs for this week
        week_costs = {subteam: 0 for subteam in subteam_budgets.keys()}

        # Iterate through each markdown file in the subdirectory
        for file in markdown_files:
            content = file.decoded_content.decode("utf-8")

            # Extract the summary content after "summary:"
            summary_marker = "summary:"
            summary_start = content.find(summary_marker)
            if summary_start != -1:
                summary_content = content[summary_start + len(summary_marker):].strip()
                week_summaries.append(summary_content)

            # Extract the spending information if it exists
            spending_matches = re.findall(r'Cost: \$([\d.]+)', content)
            for subteam_name, spending in zip(subteam_budgets.keys(), spending_matches):
                subteam_spending = float(spending)
                week_costs[subteam_name] += subteam_spending

        # Combine the extracted summaries for this week into a single string
        combined_summary = '\n\n'.join(week_summaries)

        # Check if this week is the latest week
        if week_number > latest_week_number:
            latest_week_number = week_number
            latest_week_summary = combined_summary
            latest_week_costs = week_costs

        # Update subteam budgets for the next week
        for subteam in subteam_budgets:
            subteam_budgets[subteam] -= latest_week_costs.get(subteam, 0)
            
budget_table = "\n# Budget\n| Subteam | Total | Spendings (This week) | Remaining |\n"
budget_table += "| --- | --- | --- | --- |\n"

for subteam, total_budget in subteam_budgets.items():
    # Calculate the remaining budget for each subteam
    remaining_budget = total_budget - latest_week_costs.get(subteam, 0)
    
    # Add the subteam's information to the table
    budget_table += f"| {subteam} | {total_budget} | {latest_week_costs.get(subteam, 0)} | {remaining_budget} |\n"
# Update the main readme content
new_main_readme_summary = (f"# Latest Week Summary (Week {latest_week_number}):\n{latest_week_summary}\n")

# Get the existing content of the main readme.md file
tutorial_file = repo.get_contents("tutorial.md", ref="main")
tutorial_readme = tutorial_file.decoded_content.decode("utf-8")
readme_file = repo.get_contents("README.md", ref="main")
new_readme_content = new_main_readme_summary + budget_table + tutorial_readme

# Update the main readme.md file with the combined content
# repo.update_file("README.md", "[BOT]Update the README with the latest weekly update and budget", new_readme_content, readme_file.sha, branch="main")
