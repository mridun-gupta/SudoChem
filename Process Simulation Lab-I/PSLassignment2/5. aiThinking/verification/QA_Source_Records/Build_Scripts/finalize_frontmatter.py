from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_TAB_ALIGNMENT, WD_TAB_LEADER
from docx.oxml import OxmlElement
from docx.text.paragraph import Paragraph
from docx.oxml.ns import qn
from pathlib import Path
import fitz,csv,re
DOC=Path('/mnt/data/ENERGY008_Final/Report/ENERGY008_Technical_Report.docx')
PDF=Path('/mnt/data/energy008_work/stage_render/ENERGY008_Technical_Report.pdf')
FIG=Path('/mnt/data/ENERGY008_Final/Report/Figure_Register.csv')
TAB=Path('/mnt/data/ENERGY008_Final/Report/Table_Register.csv')

def norm(s): return re.sub(r'\s+',' ',s).strip()
def short(s,n=68):
 s=norm(s)
 return s if len(s)<=n else s[:n-1].rstrip()+'…'
def page_for_phrase(doc, phrase, start=8):
 phrase=norm(phrase).lower()
 for i in range(start-1,len(doc)):
  txt=norm(doc[i].get_text()).lower()
  if phrase in txt: return i+1
 return None

d=fitz.open(PDF)
# page mapping for topic headings and appendices
anchors={}
topics=[
(1,'Assignment Purpose'),(2,'Core Problem Statement'),(3,'Project-Specific Technical Scope'),(4,'Engineering Inputs and Data'),(5,'Governing Equations and Model Formulation'),(6,'Numerical Algorithm'),(7,'Material Balances'),(8,'Energy Balance and Thermal Design'),(9,'Entropy Balance'),(10,'Exergy Balance'),(11,'Detailed Equipment Selection and Design Calculations'),(12,'PFD and P&ID-Level Definition'),(13,'Industrial Process Automation and Control'),(14,'PLC/DCS, HMI, Sequencing and Alarm Requirements'),(15,'Utilities, Environment and Waste'),(16,'CAPEX Screening'),(17,'OPEX Screening'),(18,'Sensitivity Analysis'),(19,'Flowchart Requirements'),(20,'MATLAB Modular Architecture'),(21,'GUI Requirements'),(22,'Variable Dictionary and Units'),(23,'Verification and Validation'),(24,'Python/Open-Source Migration Requirements'),(25,'Technical Report Structure'),(26,'Final Submission Package'),(27,'Acceptance Checklist')]
for n,title in topics:
 p=page_for_phrase(d,title,8)
 if p is None: raise RuntimeError(f'Could not find topic {n} {title}')
 anchors[f'topic{n:02d}']=p
for a,title in [('appA','Worked Calculation Trail'),('appB','Equipment Datasheets'),('appC','Sensitivity and Optimisation Figures'),('appD','Automation and Safety Evidence'),('appE','Open Decisions'),('appF','References and Source Provenance')]:
 p=page_for_phrase(d,title,8)
 if p is None: raise RuntimeError(f'Could not find appendix {a}')
 anchors[a]=p

# Figure/table page mapping from caption strings. For each duplicate, earliest content page is selected.
figs=list(csv.DictReader(open(FIG,encoding='utf-8')))
tabs=list(csv.DictReader(open(TAB,encoding='utf-8')))
figpages={}
for row in figs:
 n=int(row['Figure_No']); cap=norm(row['Caption'])
 # matching is based on caption phrase, skip occurrences on front lists
 hits=[]
 for i in range(7,len(d)):
  txt=norm(d[i].get_text())
  if cap[:min(35,len(cap))].lower() in txt.lower(): hits.append(i+1)
 if not hits:
  # normalized fallback
  needle=re.sub(r'[^a-z0-9 ]','',cap.lower())[:28]
  for i in range(7,len(d)):
   txt=re.sub(r'[^a-z0-9 ]','',norm(d[i].get_text()).lower())
   if needle in txt: hits.append(i+1)
 if not hits: raise RuntimeError(f'Could not locate Figure {n}: {cap}')
 figpages[n]=hits[0]

# Table captions: first page where the unique caption occurs
for row in tabs:
 n=int(row['Table_No']); cap=norm(row['Caption']); hits=[]
 needle=cap.lower()
 for i in range(0,len(d)):
  txt=norm(d[i].get_text()).lower()
  if needle in txt: hits.append(i+1)
 if not hits:
  key=cap.split('. ',1)[-1][:24].lower()
  for i in range(0,len(d)):
   if key in norm(d[i].get_text()).lower(): hits.append(i+1)
 if not hits: raise RuntimeError(f'Could not locate Table {n}: {cap}')
 row['Page']=hits[0]

# Rebuild document front matter lists + TOC page numbers
word=Document(DOC)
# update XXX beside internal TOC hyperlinks using anchor refs in XML
for p in word.paragraphs:
    if 'XXX' not in p.text: continue
    anchor=None
    for h in p._p.findall('.//'+qn('w:hyperlink')):
        anchor=h.get(qn('w:anchor'))
        if anchor: break
    if anchor in anchors:
        for t in p._p.findall('.//'+qn('w:t')):
            if t.text=='XXX': t.text=str(anchors[anchor])

# insert rows replacing placeholder paragraphs. Use an XML paragraph added immediately after the last one.
def insert_rows_at_placeholder(placeholder, records, kind):
    ph=next((p for p in word.paragraphs if placeholder in p.text),None)
    if ph is None: raise RuntimeError('Missing placeholder: '+placeholder)
    parent=ph._parent
    last=ph._p
    ph._p.getparent().remove(ph._p)
    for rec in records:
        el=OxmlElement('w:p'); last.addnext(el); last=el
        p=Paragraph(el,parent)
        p.paragraph_format.space_after=Pt(0.6)
        p.paragraph_format.space_before=Pt(0)
        p.paragraph_format.line_spacing=1.0
        p.paragraph_format.tab_stops.add_tab_stop(Inches(6.55),WD_TAB_ALIGNMENT.RIGHT,WD_TAB_LEADER.DOTS)
        p.paragraph_format.keep_together=True
        text=short(rec['Caption'],72)
        if kind=='Figure':
            no=int(rec['Figure_No']); anchor=f'fig{no}'; page=figpages[no]
            h=OxmlElement('w:hyperlink'); h.set(qn('w:anchor'),anchor)
            r=OxmlElement('w:r'); rp=OxmlElement('w:rPr')
            col=OxmlElement('w:color'); col.set(qn('w:val'),'1F4E79'); rp.append(col)
            u=OxmlElement('w:u'); u.set(qn('w:val'),'single'); rp.append(u)
            sz=OxmlElement('w:sz'); sz.set(qn('w:val'),'15'); rp.append(sz)
            r.append(rp); t=OxmlElement('w:t'); t.text=f"Figure {no}. {text}"; r.append(t); h.append(r); p._p.append(h)
        else:
            no=int(rec['Table_No']); anchor=f"tbl{no}"; page=int(rec['Page'])
            h=OxmlElement('w:hyperlink'); h.set(qn('w:anchor'),anchor)
            r=OxmlElement('w:r'); rp=OxmlElement('w:rPr')
            col=OxmlElement('w:color'); col.set(qn('w:val'),'1F4E79'); rp.append(col)
            u=OxmlElement('w:u'); u.set(qn('w:val'),'single'); rp.append(u)
            sz=OxmlElement('w:sz'); sz.set(qn('w:val'),'15'); rp.append(sz)
            r.append(rp); t=OxmlElement('w:t'); t.text=f"Table {no}. {text}"; r.append(t); h.append(r); p._p.append(h)
        rn=p.add_run('\t'+str(page)); rn.font.name='Times New Roman'; rn.font.size=Pt(7.5); rn.font.color.rgb=RGBColor(70,70,70)
    # The final inserted paragraph remains before the existing page-break paragraph.

insert_rows_at_placeholder('Figure list page entries are updated from the final rendered document.',figs,'Figure')
insert_rows_at_placeholder('Table list page entries are updated from the final rendered document.',tabs,'Table')
word.save(DOC)

# Add final page numbers to registers (pages from pre-insertion pass; list pages occupied one page each, so downstream pages remain invariant).
with open(FIG,'w',newline='',encoding='utf-8') as f:
 w=csv.DictWriter(f,fieldnames=['Figure_No','Caption','Units_Status','Source_File','Page']); w.writeheader()
 for row in figs: row['Page']=figpages[int(row['Figure_No'])]; w.writerow(row)
with open(TAB,'w',newline='',encoding='utf-8') as f:
 w=csv.DictWriter(f,fieldnames=['Table_No','Caption','Units_Status','Page']); w.writeheader(); w.writerows(tabs)
with open('/mnt/data/energy008_work/page_map.json','w') as f:
 import json; json.dump({'toc':anchors,'figures':figpages,'tables':{r['Table_No']:r['Page'] for r in tabs}},f,indent=2)
print('UPDATED FRONTMATTER', 'toc',anchors, 'figures',len(figpages),'tables',len(tabs))
