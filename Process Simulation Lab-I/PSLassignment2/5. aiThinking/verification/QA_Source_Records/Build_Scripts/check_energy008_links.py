from pathlib import Path
from zipfile import ZipFile
from xml.etree import ElementTree as ET
import re, json, sys
root=Path('/mnt/data/ENERGY-008_Submission')
issues=[]
# Validate markdown links in all markdown files.
md_files=list(root.rglob('*.md'))
link_re=re.compile(r'(?<!!)\[[^\]]*\]\(([^)]+)\)|!\[[^\]]*\]\(([^)]+)\)')
checked=0
for md in md_files:
    text=md.read_text(encoding='utf-8',errors='replace')
    for m in link_re.finditer(text):
        target=(m.group(1) or m.group(2) or '').strip()
        target=target.split()[0].strip('<>')
        if not target or target.startswith(('#','http://','https://','mailto:','data:')):
            continue
        target=target.split('#',1)[0].split('?',1)[0]
        if not target: continue
        checked+=1
        q=(md.parent/target).resolve()
        if not q.exists(): issues.append(f'Markdown link missing: {md.relative_to(root)} -> {target}')
# Check important path tokens in the top-level README.
readme=(root/'README.md').read_text(encoding='utf-8')
required=[
 'Original_Assignment/PSLassignment2.pdf','Report/ENERGY008_Technical_Report.docx',
 'Report/ENERGY008_Technical_Report.pdf','Presentation/ENERGY008_Short_Presentation.pptx',
 'MATLAB/START_HERE.m','MATLAB/project_config.json','MATLAB/tests/run_startup_smoke_test.m',
 'MATLAB/run_prompt19_tests.m','MATLAB/run_gui.m','Python/README.md','Python/requirements.lock',
 'Python/results/','data/raw/','data/data_manifest.json','Registers/','Calculations/',
 'Results/Sensitivity_Optimisation/','Tests/','Logs/','PFD_PID/','Flowcharts/','Equipment_Datasheets/',
 'Control_Sequence/','Environment_Safety/','Sources/Bibliography/','Archive/Phase_Evidence/',
 'QA/Final_Audit_Report.md','QA/Final_Compliance_Matrix.xlsx','QA/ENERGY008_Open_Issues.md','ENERGY-008_Submission_Manifest.csv'
]
for item in required:
    p=item.rstrip('/')
    if '*' in p: continue
    if not (root/p).exists(): issues.append(f'Root README required path missing: {item}')
# Verify DOCX internal bookmark hyperlink targets and external file links.
docx=root/'Report/ENERGY008_Technical_Report.docx'
ns={'w':'http://schemas.openxmlformats.org/wordprocessingml/2006/main','r':'http://schemas.openxmlformats.org/officeDocument/2006/relationships'}
with ZipFile(docx) as z:
    doc=ET.fromstring(z.read('word/document.xml'))
    bookmarks={el.attrib.get('{%s}name'%ns['w']) for el in doc.findall('.//w:bookmarkStart',ns)}
    anchors=[]
    for el in doc.findall('.//w:hyperlink',ns):
        a=el.attrib.get('{%s}anchor'%ns['w'])
        if a: anchors.append(a)
    for a in anchors:
        if a not in bookmarks: issues.append(f'DOCX internal hyperlink bookmark missing: {a}')
    rel_root=ET.fromstring(z.read('word/_rels/document.xml.rels'))
    external=[]
    for rel in rel_root:
        if rel.attrib.get('TargetMode')=='External': external.append(rel.attrib.get('Target',''))
    bad_external=[u for u in external if u.lower().startswith(('file:','\\\\'))]
    if bad_external: issues.append('DOCX external file links present: '+repr(bad_external))
# Verify PDF internal links point to an in-range page.
pdf=root/'Report/ENERGY008_Technical_Report.pdf'
try:
    import fitz
    d=fitz.open(pdf); n=len(d); internal=0; bad=[]
    for pi,page in enumerate(d):
        for link in page.get_links():
            if link.get('kind')==fitz.LINK_GOTO:
                internal+=1
                tp=link.get('page')
                if tp is None or tp<0 or tp>=n: bad.append((pi+1,tp))
    if bad: issues.append('PDF internal links out of range: '+repr(bad[:20]))
    pdf_info={'pages':n,'internal_goto_links':internal,'bad_internal_links':len(bad)}
except Exception as e:
    pdf_info={'error':str(e)}; issues.append('PDF link inspection unavailable: '+str(e))
print(json.dumps({'markdown_files':len(md_files),'markdown_local_links_checked':checked,'docx_bookmarks':len(bookmarks),'docx_internal_hyperlinks':len(anchors),'docx_external_links':len(external),'pdf':pdf_info,'issues':issues},indent=2))
if issues: sys.exit(1)
