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
    "Aerodynamics Team": 2000,
    "Structures Team (Wed)": 2000,
    "Structures Team (Fri)": 2000,
    "Payload Team": 8000,
    "Systems(Traveling) Team": 2000,
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
            spending_match = re.search(r'Costs:\s*\$([\d.]+)', content)
            if spending_match:
                subteam_name = content.split('\n')[0].strip()  # Get the first line which contains the subteam name
                subteam_spending = float(spending_match.group(1))
                subteam_spendings[subteam_name] = subteam_spendings.get(subteam_name, 0) + subteam_spending

        # Combine the extracted summaries for this week into a single string
        combined_summary = '\n\n'.join(week_summaries)

        # Check if this week is the latest week
        if week_number > latest_week_number:
            latest_week_number = week_number
            latest_week_summary = combined_summary

# Generate the budget table
budget_table = "\n# Budget\n| Subteam | Total | Spendings (This week) | Remaining |\n"
budget_table += "| --- | --- | --- | --- |\n"

for subteam, total_budget in subteam_budgets.items():
    # Calculate the remaining budget for each subteam
    remaining_budget = total_budget - subteam_spendings.get(subteam, 0)
    
    # Add the subteam's information to the table
    budget_table += f"| {subteam} | ${total_budget} | ${subteam_spendings.get(subteam, 0)} | ${remaining_budget} |\n"

# Update the main readme content
new_main_readme_summary = (f"# Latest Week Summary (Week {latest_week_number}):\n{latest_week_summary}\n")

# Get the existing content of the main readme.md file
tutorial_file = repo.get_contents("tutorial.md", ref="main")
tutorial_readme = tutorial_file.decoded_content.decode("utf-8")
readme_file = repo.get_contents("README.md", ref="main")
new_readme_content = new_main_readme_summary + budget_table + tutorial_readme

# Update the main readme.md file with the combined content
repo.update_file("README.md", "Update the README with the latest weekly update and budget", new_readme_content, readme_file.sha, branch="main")
