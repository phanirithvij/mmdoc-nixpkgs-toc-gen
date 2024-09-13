# heavily chatgpt generated
# can't be bothered to waste time
# hand modified later

import sys
from bs4 import BeautifulSoup

if len(sys.argv) < 2:
    print("Usage: python generate_toc.py <path_to_html_file>")
    sys.exit(1)

file_path = sys.argv[1]

with open(file_path, "r", encoding="utf-8") as file:
    html_content = file.read()

soup = BeautifulSoup(html_content, "html.parser")

markdown_toc = []


def generate_markdown_link(title, href, indent_level):
    indent = "  " * indent_level
    return f"{indent}- [{title}]({href})"


# heading
markdown_toc.append("# Nixpkgs Manual (mmdoc)")

# version
markdown_toc.append(soup.select_one("h2.subtitle").text)

current_chapter = None

toc = soup.select_one("dl.toc")

for item in toc.find_all("span"):
    a_tag = item.find("a")
    if a_tag:
        title = a_tag.text.strip()
        href = a_tag["href"]

        if "part" in item["class"]:
            markdown_toc.append(f"## {title}")
        elif "chapter" in item["class"]:
            markdown_toc.append(generate_markdown_link("", href, 0))
            current_chapter = href
        elif "section" in item["class"]:
            if current_chapter[6:] in [
                "special",
                "images",
                "hooks",
                "language-support",
                "packages",
                "functions",  # lib functions chap
            ]:
                if href == "#sec-functions-library":
                    continue
                markdown_toc.append(generate_markdown_link("", href, 1))

# Join the list to form the final markdown
final_markdown = "\n".join(markdown_toc)
print(final_markdown)
