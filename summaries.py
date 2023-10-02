import os
import re
from github import Github
import sys


repository_name = 'https://github.com/adevine2147/CPPDBF23-24'

# Define the GitHub token secret name
github_token_secret_name = 'GH_PAT'

# Get the GitHub token from the secret
#github_token = os.getenv(github_token_secret_name)
github_token = "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"

# Check if the token is available
if github_token is None:
    sys.exit(f"GitHub token '{github_token_secret_name}' not found in environment variables.")

# Initialize the GitHub API client with the token
g = Github(github_token)
repo = g.get_user().get_repo(repository_name)

# Define the folder containing weekly update markdown files
folder_path = 'systems/updates'

# List all directories in the folder
directories = [directory for directory in repo.get_contents(folder_path, ref="main") if directory.type == 'dir']

# Initialize a dictionary to store summaries by week number
summaries_by_week = {}

# Initialize a variable to store the combined summary for the main readme
combined_main_readme_summary = ""

# Iterate through each directory
for directory in directories:
    # List all markdown files in the subdirectory
    files = repo.get_contents(directory.path, ref="main")
    markdown_files = [file for file in files if file.name.endswith(".md")]

    # Determine the week number from the directory name
    week_match = re.match(r'^(\d+)_\w+$', directory.name)
    if week_match:
        week_number = int(week_match.group(1))
    else:
        continue  # Skip directories with invalid names

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

    # Combine the extracted summaries for this week into a single string
    combined_summary = '\n\n'.join(week_summaries)

    # Define the filename for the week's summary
    summary_filename = f"{week_number}_subteam.md"
    summary_path = os.path.join(folder_path, summary_filename)

    # Create or update the summary file
    repo.update_file(summary_path, f"Update summary for week {week_number}", combined_summary, branch="main")

    # Store the combined summary in the dictionary
    summaries_by_week[week_number] = combined_summary

    # Append this week's summary to the combined main readme summary
    combined_main_readme_summary += f"\n## Week {week_number} Summary\n\n{combined_summary}"

# Get the existing content of the main readme.md file
readme_file = repo.get_contents("readme.md", ref="main")
existing_readme_content = readme_file.decoded_content.decode("utf-8")

# Combine the existing content and the new summaries
updated_readme_content = existing_readme_content + combined_main_readme_summary

# Update the main readme.md file with the combined summaries
repo.update_file("readme.md", "Update the README with the latest weekly update", updated_readme_content, readme_file.sha, branch="main")
