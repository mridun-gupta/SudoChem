from docx import Document
from docx.shared import Inches,Pt,RGBColor
from docx.enum.text import WD_TAB_ALIGNMENT,WD_TAB_LEADER
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.text.paragraph import Paragraph
import csv,re
from pathlib import Path
DOC=Path('/mnt/data/ENERGY008_Final/Report/ENERGY008_Technical_Report.docx')
FIG=list(csv.DictReader(open('/mnt/data/ENERGY008_Final/Report/Figure_Register.csv',encoding='utf-8')))
TAB=list(csv.DictReader(open('/mnt/data/ENERGY008_Final/Report/Table_Register.csv',encoding='utf-8')))
d=Document(DOC)

def trunc(s,n=78):
 s=' '.join(s.split())
 return s if len(s)<=n else s[:n-1].rstrip()+'…'

def insert_after_placeholder(placeholder, records, kind):
 intro = ('Figure captions state the plotted variables/units and the evidence status.' if kind=='Figure' else 'Table captions identify the units and the evidence boundary.')
 ph=next((p for p in d.paragraphs if intro in p.text),None)
 if ph is None: raise RuntimeError('intro absent '+intro)
 last=ph._p
 for rec in records:
  el=OxmlElement('w:p'); last.addnext(el); last=el
  p=Paragraph(el,d)
  p.paragraph_format.space_before=Pt(0);p.paragraph_format.space_after=Pt(.6);p.paragraph_format.line_spacing=1.0;p.paragraph_format.keep_together=True
  p.paragraph_format.tab_stops.add_tab_stop(Inches(6.55),WD_TAB_ALIGNMENT.RIGHT,WD_TAB_LEADER.DOTS)
  if kind=='Figure': no=int(rec['Figure_No']); anc=f'fig{no}'; pg=rec['Page']; label=f"Figure {no}. {trunc(rec['Caption'])}"
  else: no=int(rec['Table_No']); anc=f'tbl{no}'; pg=rec['Page']; cap=re.sub(rf'^Table\s+{no}\.\s*','',rec['Caption']); label=f"Table {no}. {trunc(cap)}"
  h=OxmlElement('w:hyperlink');h.set(qn('w:anchor'),anc)
  r=OxmlElement('w:r');rp=OxmlElement('w:rPr')
  c=OxmlElement('w:color');c.set(qn('w:val'),'1F4E79');rp.append(c)
  u=OxmlElement('w:u');u.set(qn('w:val'),'single');rp.append(u)
  sz=OxmlElement('w:sz');sz.set(qn('w:val'),'15');rp.append(sz)
  r.append(rp);t=OxmlElement('w:t');t.text=label;r.append(t);h.append(r);p._p.append(h)
  q=p.add_run('\t'+str(pg));q.font.name='Times New Roman';q.font.size=Pt(7.5);q.font.color.rgb=RGBColor(70,70,70)
 # fix introductory text
 if kind=='Figure':
  for p in d.paragraphs:
   if 'Page numbers are populated after final PDF rendering.' in p.text:
    for r in p.runs:r.text=r.text.replace('Page numbers are populated after final PDF rendering.','Page numbers refer to the final rendered Rev 1.0 report; select a caption to jump to its figure.')
    break

insert_after_placeholder('Figure list page entries are updated from the final rendered document.',FIG,'Figure')
insert_after_placeholder('Table list page entries are updated from the final rendered document.',TAB,'Table')
d.save(DOC)
print('Inserted',len(FIG),'figure list rows and',len(TAB),'table list rows')
