import xml.etree.ElementTree as ET
from html import unescape
from bs4 import BeautifulSoup

# 加载并解析 kdist.xml
with open("kdist.xml", "r", encoding="utf-8") as f:
    tree = ET.parse(f)
    root = tree.getroot()

# 命名空间（如果有的话）
channel = root.find("channel")

print("最新 Linux 内核版本列表：\n")

for item in channel.findall("item"):
    title = item.findtext("title")
    pub_date = item.findtext("pubDate")
    description = item.findtext("description")

    # description 是 HTML 编码的字符串，需要先 unescape，再用 BeautifulSoup 解析
    html_desc = unescape(description)
    soup = BeautifulSoup(html_desc, "html.parser")

    # 提取 ChangeLog 链接（如果存在）
    changelog_link = None
    for tr in soup.find_all("tr"):
        th = tr.find("th")
        td = tr.find("td")
        if th and "ChangeLog" in th.get_text():
            a = td.find("a")
            if a:
                changelog_link = a.get("href")

    print(f"版本: {title}")
    print(f"发布时间: {pub_date}")
    if changelog_link:
        print(f"ChangeLog: {changelog_link}")
    else:
        print("ChangeLog: 无")
    print("-" * 60)
