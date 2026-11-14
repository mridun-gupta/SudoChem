from docx import Document
from docx.oxml.ns import qn
import fitz,re,json
from pathlib import Path
DOC=Path('/mnt/data/ENERGY008_Final/Report/ENERGY008_Technical_Report.docx')
PDF=fitz.open('/mnt/data/energy008_work/stage_render/ENERGY008_Technical_Report.pdf')
mapdata=json.load(open('/mnt/data/energy008_work/page_map.json'))
topics=[
(1,'Assignment Purpose'),(2,'Core Problem Statement'),(3,'Project-Specific Technical Scope'),(4,'Engineering Inputs and Data'),(5,'Governing Equations and Model Formulation'),(6,'Numerical Algorithm'),(7,'Material Balances'),(8,'Energy Balance and Thermal Design'),(9,'Entropy Balance'),(10,'Exergy Balance'),(11,'Detailed Equipment Selection and Design Calculations'),(12,'PFD and P&ID-Level Definition'),(13,'Industrial Process Automation and Control'),(14,'PLC/DCS, HMI, Sequencing and Alarm Requirements'),(15,'Utilities, Environment and Waste'),(16,'CAPEX Screening'),(17,'OPEX Screening'),(18,'Sensitivity Analysis'),(19,'Flowchart Requirements'),(20,'MATLAB Modular Architecture'),(21,'GUI Requirements'),(22,'Variable Dictionary and Units'),(23,'Verification and Validation'),(24,'Python/Open-Source Migration Requirements'),(25,'Technical Report Structure'),(26,'Final Submission Package'),(27,'Acceptance Checklist')]
anchors={}
for n,title in topics:
    needle=f'{n}. {title}'
    hits=[]
    for i,p in enumerate(PDF):
        for line in p.get_text().splitlines():
            if line.strip()==needle: hits.append(i+1)
    if not hits: raise RuntimeError('Missing heading '+needle)
    anchors[f'topic{n:02d}']=hits[0]
for a,needle in [('appA','Appendix A. Worked Calculation Trail'),('appB','Appendix B. Equipment Datasheets'),('appC','Appendix C. Sensitivity and Optimisation Figures'),('appD','Appendix D. Automation and Safety Evidence'),('appE','Appendix E. Open Decisions, Limitations and Recommendations'),('appF','Appendix F. References and Source Provenance')]:
    hits=[]
    for i,p in enumerate(PDF):
        if needle in p.get_text(): hits.append(i+1)
    if not hits: raise RuntimeError('Missing '+needle)
    anchors[a]=hits[0]

d=Document(DOC)
for p in d.paragraphs:
    h=None
    for x in p._p.findall('.//'+qn('w:hyperlink')):
        if x.get(qn('w:anchor')):
            h=x;break
    if h is None: continue
    anchor=h.get(qn('w:anchor'))
    if anchor not in anchors: continue
    # numeric page is in the non-hyperlink run; replace the final text node after the link
    for r in p._p.findall('./'+qn('w:r')):
        t=r.find(qn('w:t'))
        if t is not None and (t.text or '').strip().isdigit():
            t.text=str(anchors[anchor])
            break

d.save(DOC)
mapdata['toc']=anchors
json.dump(mapdata,open('/mnt/data/energy008_work/page_map.json','w'),indent=2)
print(json.dumps(anchors,indent=2))
