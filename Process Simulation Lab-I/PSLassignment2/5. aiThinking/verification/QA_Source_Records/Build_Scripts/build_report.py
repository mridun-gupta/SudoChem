from pathlib import Path
import os, re, math, csv, json, shutil, textwrap
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_BREAK, WD_TAB_ALIGNMENT, WD_TAB_LEADER
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_CELL_VERTICAL_ALIGNMENT
from docx.enum.section import WD_SECTION
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.enum.style import WD_STYLE_TYPE
from artifact_tool import Blob, SpreadsheetFile
from PIL import Image, ImageDraw
import matplotlib.pyplot as plt

ROOT = Path('/mnt/data/ENERGY008_Final')
SRC = Path('/mnt/data/energy008_sources')
ASSET = SRC/'phase_assets'
REG = SRC/'registers'
DSDIR = SRC/'ENERGY008_Equipment_Datasheets_v0.1.0'/'Datasheets'
PLOT = SRC/'ENERGY008_Prompt22_Sensitivity_Optimisation'/'22_Sensitivity_Optimisation'/'Plots'
PID_RENDER = Path('/mnt/data/pid_render')
OUT = ROOT/'Report'/'ENERGY008_Technical_Report.docx'

# ---- Utility formatting ----
NAVY = '17365D'; BLUE = '1F4E79'; MIDBLUE = 'D9EAF7'; PALE = 'EEF3F8'; GREY = 'F2F2F2'; DARK = '222222'; WHITE = 'FFFFFF'; AMBER = 'FCE4D6'

def set_cell_shading(cell, fill):
    tcPr = cell._tc.get_or_add_tcPr(); shd = tcPr.find(qn('w:shd'))
    if shd is None: shd = OxmlElement('w:shd'); tcPr.append(shd)
    shd.set(qn('w:fill'), fill)

def set_cell_margins(cell, top=80, start=90, bottom=80, end=90):
    tc = cell._tc; tcPr = tc.get_or_add_tcPr(); tcMar = tcPr.first_child_found_in('w:tcMar')
    if tcMar is None: tcMar = OxmlElement('w:tcMar'); tcPr.append(tcMar)
    for m,v in [('top',top),('start',start),('bottom',bottom),('end',end)]:
        node = tcMar.find(qn('w:'+m))
        if node is None: node = OxmlElement('w:'+m); tcMar.append(node)
        node.set(qn('w:w'),str(v)); node.set(qn('w:type'),'dxa')

def set_repeat_table_header(row):
    trPr = row._tr.get_or_add_trPr(); tblHeader = OxmlElement('w:tblHeader'); tblHeader.set(qn('w:val'),'true'); trPr.append(tblHeader)

def prevent_row_split(row):
    trPr = row._tr.get_or_add_trPr(); el=OxmlElement('w:cantSplit'); trPr.append(el)

def add_bookmark(paragraph, name, bid):
    start = OxmlElement('w:bookmarkStart'); start.set(qn('w:id'), str(bid)); start.set(qn('w:name'), name)
    end = OxmlElement('w:bookmarkEnd'); end.set(qn('w:id'), str(bid))
    paragraph._p.insert(0,start); paragraph._p.append(end)

def add_internal_hyperlink(paragraph, anchor, text, color=BLUE, underline=True, size=8):
    h = OxmlElement('w:hyperlink'); h.set(qn('w:anchor'), anchor)
    r = OxmlElement('w:r'); rPr=OxmlElement('w:rPr')
    c=OxmlElement('w:color'); c.set(qn('w:val'), color); rPr.append(c)
    if underline:
        u=OxmlElement('w:u'); u.set(qn('w:val'),'single'); rPr.append(u)
    sz=OxmlElement('w:sz'); sz.set(qn('w:val'), str(int(size*2))); rPr.append(sz)
    r.append(rPr); t=OxmlElement('w:t'); t.text=text; r.append(t); h.append(r); paragraph._p.append(h)
    return h

def add_external_hyperlink(paragraph, url, text, color=BLUE):
    part = paragraph.part
    rid = part.relate_to(url, 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink', is_external=True)
    h=OxmlElement('w:hyperlink'); h.set(qn('r:id'), rid)
    r=OxmlElement('w:r'); rp=OxmlElement('w:rPr'); c=OxmlElement('w:color'); c.set(qn('w:val'),color); rp.append(c)
    u=OxmlElement('w:u'); u.set(qn('w:val'),'single'); rp.append(u); r.append(rp)
    t=OxmlElement('w:t'); t.text=text; r.append(t); h.append(r); paragraph._p.append(h)

def add_page_field(paragraph):
    run = paragraph.add_run()
    fldChar1 = OxmlElement('w:fldChar'); fldChar1.set(qn('w:fldCharType'), 'begin')
    instrText = OxmlElement('w:instrText'); instrText.set(qn('xml:space'),'preserve'); instrText.text = ' PAGE '
    fldChar2 = OxmlElement('w:fldChar'); fldChar2.set(qn('w:fldCharType'), 'end')
    run._r.append(fldChar1); run._r.append(instrText); run._r.append(fldChar2)

def add_math_equation(doc, text):
    p=doc.add_paragraph(); p.alignment=WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before=Pt(3); p.paragraph_format.space_after=Pt(5)
    pPr=p._p.get_or_add_pPr()
    jc=OxmlElement('w:jc'); jc.set(qn('w:val'),'center'); pPr.append(jc)
    om=OxmlElement('m:oMath'); r=OxmlElement('m:r'); t=OxmlElement('m:t'); t.text=text; r.append(t); om.append(r); p._p.append(om)
    return p

def set_run_font(run, name='Times New Roman', size=11, color=None, bold=None, italic=None):
    run.font.name=name; run._element.get_or_add_rPr().rFonts.set(qn('w:ascii'),name); run._element.get_or_add_rPr().rFonts.set(qn('w:hAnsi'),name)
    run.font.size=Pt(size)
    if color: run.font.color.rgb=RGBColor.from_string(color)
    if bold is not None: run.bold=bold
    if italic is not None: run.italic=italic

def format_paragraph(p, after=5, before=0, line=1.12, keep=False):
    p.paragraph_format.space_after=Pt(after); p.paragraph_format.space_before=Pt(before); p.paragraph_format.line_spacing=line
    if keep: p.paragraph_format.keep_with_next=True
    for r in p.runs:
        set_run_font(r, size=r.font.size.pt if r.font.size else 11)

def add_rich_text(p, text, size=10.5, color=DARK):
    # basic markdown inline emphasis + inline-code
    parts=re.split(r'(\*\*.*?\*\*|`.*?`|\*[^*]+\*)', text)
    for s in parts:
        if not s: continue
        if s.startswith('**') and s.endswith('**'):
            r=p.add_run(s[2:-2]); set_run_font(r,size=size,color=color,bold=True)
        elif s.startswith('`') and s.endswith('`'):
            r=p.add_run(s[1:-1]); set_run_font(r,name='Consolas',size=size,color='444444')
        elif s.startswith('*') and s.endswith('*'):
            r=p.add_run(s[1:-1]); set_run_font(r,size=size,color=color,italic=True)
        else:
            r=p.add_run(s); set_run_font(r,size=size,color=color)
    return p

def add_para(doc, text, style=None, after=5, size=10.5, color=DARK, before=0):
    p=doc.add_paragraph(style=style); add_rich_text(p, text, size=size, color=color); p.paragraph_format.space_after=Pt(after); p.paragraph_format.space_before=Pt(before); p.paragraph_format.line_spacing=1.12
    return p

def add_bullet(doc, text, level=0, size=10.2):
    style='List Bullet' if level==0 else 'List Bullet 2'
    p=doc.add_paragraph(style=style); add_rich_text(p,text,size=size); p.paragraph_format.space_after=Pt(3); p.paragraph_format.line_spacing=1.05; return p

def add_number(doc, text, size=10.2):
    p=doc.add_paragraph(style='List Number'); add_rich_text(p,text,size=size); p.paragraph_format.space_after=Pt(3); p.paragraph_format.line_spacing=1.05; return p

def add_heading(doc, text, level=1, bookmark=None):
    p=doc.add_paragraph(style=f'Heading {level}'); r=p.add_run(text); set_run_font(r,size={1:15,2:12.5,3:11}[level],color=BLUE,bold=True)
    p.paragraph_format.keep_with_next=True; p.paragraph_format.space_before=Pt({1:12,2:8,3:5}[level]); p.paragraph_format.space_after=Pt({1:7,2:4,3:3}[level])
    if bookmark: add_bookmark(p,bookmark,bookmark_counter())
    return p

_bookmark_id=10
def bookmark_counter():
    global _bookmark_id; _bookmark_id += 1; return _bookmark_id

def add_back_link(doc, anchor='Contents'):
    p=doc.add_paragraph(); p.alignment=WD_ALIGN_PARAGRAPH.RIGHT; p.paragraph_format.space_after=Pt(3)
    add_internal_hyperlink(p,anchor,'Back to Contents',size=8,color='666666')
    return p

def add_topic_heading(doc, number, title):
    p=add_heading(doc, f'{number}. {title}',1,bookmark=f'topic{number:02d}')
    add_back_link(doc)
    return p

def add_sub(doc, title): return add_heading(doc,title,2)

def add_table(doc, headers, rows, caption, units='Units are stated by column; blanks indicate not available.', widths=None, font=8.2):
    global TABLE_REG
    n=len(headers); t=doc.add_table(rows=1,cols=n); t.alignment=WD_TABLE_ALIGNMENT.CENTER; t.style='Table Grid'; t.autofit=True
    tr=t.rows[0]; set_repeat_table_header(tr); prevent_row_split(tr)
    for i,h in enumerate(headers):
        c=tr.cells[i]; c.text=''; set_cell_shading(c,NAVY); set_cell_margins(c)
        pp=c.paragraphs[0]; pp.alignment=WD_ALIGN_PARAGRAPH.CENTER; pp.paragraph_format.space_after=Pt(0)
        rr=pp.add_run(str(h)); set_run_font(rr,size=font,color=WHITE,bold=True)
    for ri,row in enumerate(rows):
        cells=t.add_row().cells; prevent_row_split(t.rows[-1])
        for ci,val in enumerate(row):
            c=cells[ci]; c.vertical_alignment=WD_CELL_VERTICAL_ALIGNMENT.CENTER; set_cell_margins(c,top=65,bottom=65)
            if ri%2==1: set_cell_shading(c,'F5F8FB')
            c.text=''; pp=c.paragraphs[0]; pp.paragraph_format.space_after=Pt(0); pp.paragraph_format.line_spacing=1.0
            # long text smaller; keep compact.
            rr=pp.add_run('' if val is None else str(val)); set_run_font(rr,size=font,color=DARK)
    if widths:
        for row in t.rows:
            for i,w in enumerate(widths):
                row.cells[i].width=Inches(w)
    p=doc.add_paragraph(); p.paragraph_format.space_before=Pt(2); p.paragraph_format.space_after=Pt(2)
    add_rich_text(p,caption+f' ({units})',size=8.6,color='333333')
    p.paragraph_format.keep_with_next=True
    TABLE_REG.append({'caption':caption,'units':units,'bookmark':f'tbl{len(TABLE_REG)+1}'})
    add_bookmark(p,TABLE_REG[-1]['bookmark'],bookmark_counter())
    return t

FIG_REG=[]; TABLE_REG=[]
def add_figure(doc, path, caption, units='Units: see axes/diagram; not applicable for PFD/P&ID.', width=6.65, height=None, pagebreak=False):
    path=Path(path)
    if not path.exists():
        add_para(doc, f'[Figure asset unavailable in source package: {path.name}]', size=9, color='AA0000'); return None
    if pagebreak: doc.add_page_break()
    p=doc.add_paragraph(); p.alignment=WD_ALIGN_PARAGRAPH.CENTER; p.paragraph_format.space_after=Pt(2)
    try:
        if height: p.add_run().add_picture(str(path),width=Inches(width),height=Inches(height))
        else: p.add_run().add_picture(str(path),width=Inches(width))
    except Exception:
        p.add_run().add_picture(str(path),width=Inches(width))
    num=len(FIG_REG)+1; cap=doc.add_paragraph(); cap.alignment=WD_ALIGN_PARAGRAPH.CENTER; cap.paragraph_format.space_after=Pt(6)
    add_rich_text(cap,f'Figure {num}. {caption} ({units})',size=8.6,color='333333')
    b=f'fig{num}'; add_bookmark(cap,b,bookmark_counter()); FIG_REG.append({'number':num,'caption':caption,'units':units,'path':str(path),'bookmark':b})
    return num

def add_callout(doc, label, text, fill=PALE):
    t=doc.add_table(rows=1,cols=1); t.autofit=True; c=t.cell(0,0); set_cell_shading(c,fill); set_cell_margins(c,top=120,start=160,bottom=120,end=160)
    p=c.paragraphs[0]; add_rich_text(p,f'{label}: {text}',size=9.4,color=DARK); p.paragraph_format.space_after=Pt(1)
    doc.add_paragraph().paragraph_format.space_after=Pt(1)
    return t

def add_page_break(doc): doc.add_page_break()

# Document setup
doc=Document(); sec=doc.sections[0]
sec.page_width=Inches(8.27); sec.page_height=Inches(11.69); sec.top_margin=Inches(.72); sec.bottom_margin=Inches(.72); sec.left_margin=Inches(.78); sec.right_margin=Inches(.72)
# styles
styles=doc.styles
for stylename in ['Normal','Body Text','List Bullet','List Bullet 2','List Number']:
    st=styles[stylename]; st.font.name='Times New Roman'; st._element.rPr.rFonts.set(qn('w:ascii'),'Times New Roman'); st._element.rPr.rFonts.set(qn('w:hAnsi'),'Times New Roman'); st.font.size=Pt(10.5); st.font.color.rgb=RGBColor.from_string(DARK)
    st.paragraph_format.space_after=Pt(4); st.paragraph_format.line_spacing=1.12
for i in range(1,4):
    st=styles[f'Heading {i}']; st.font.name='Times New Roman'; st._element.rPr.rFonts.set(qn('w:ascii'),'Times New Roman'); st._element.rPr.rFonts.set(qn('w:hAnsi'),'Times New Roman'); st.font.color.rgb=RGBColor.from_string(BLUE); st.font.bold=True; st.font.size=Pt({1:15,2:12.5,3:11}[i]); st.paragraph_format.keep_with_next=True
# Header and footer
header=sec.header.paragraphs[0]; header.alignment=WD_ALIGN_PARAGRAPH.RIGHT
rr=header.add_run('ENERGY-008  |  GREEN METHANOL SYNTHESIS'); set_run_font(rr,size=8,color='666666',bold=True)
footer=sec.footer.paragraphs[0]; footer.alignment=WD_ALIGN_PARAGRAPH.CENTER
r=footer.add_run('ENERGY008-REP-001  |  Rev 1.0  |  Page '); set_run_font(r,size=8,color='666666')
add_page_field(footer)
r=footer.add_run(' of '); set_run_font(r,size=8,color='666666')
r2=footer.add_run(); b=OxmlElement('w:fldChar'); b.set(qn('w:fldCharType'),'begin'); i=OxmlElement('w:instrText'); i.set(qn('xml:space'),'preserve'); i.text=' NUMPAGES '; e=OxmlElement('w:fldChar'); e.set(qn('w:fldCharType'),'end'); r2._r.append(b); r2._r.append(i); r2._r.append(e)

# ---- COVER ----
p=doc.add_paragraph(); p.alignment=WD_ALIGN_PARAGRAPH.CENTER; p.paragraph_format.space_before=Pt(75)
r=p.add_run('ENERGY ASSIGNMENT 008'); set_run_font(r,size=16,color=BLUE,bold=True)
p=doc.add_paragraph(); p.alignment=WD_ALIGN_PARAGRAPH.CENTER; p.paragraph_format.space_before=Pt(18)
r=p.add_run('GREEN METHANOL SYNTHESIS'); set_run_font(r,size=25,color=NAVY,bold=True)
p=doc.add_paragraph(); p.alignment=WD_ALIGN_PARAGRAPH.CENTER
r=p.add_run('Utility Integration and Energy KPIs'); set_run_font(r,size=18,color=BLUE)
p=doc.add_paragraph(); p.alignment=WD_ALIGN_PARAGRAPH.CENTER; p.paragraph_format.space_before=Pt(15)
r=p.add_run('FINAL CONSOLIDATED ENGINEERING REPORT'); set_run_font(r,size=13,color='666666',bold=True)
p=doc.add_paragraph(); p.alignment=WD_ALIGN_PARAGRAPH.CENTER; p.paragraph_format.space_before=Pt(4)
r=p.add_run('Academic process design and model-evidence review'); set_run_font(r,size=10.5,color='666666',italic=True)
# identification table
rows=[
('Project ID','ENERGY-008'),('Sector','Energy and Renewable Industrial Systems'),('Working route','Route C: biogenic CO2 + renewable electrolytic H2; ALK reference'),('Alternatives','Route A: existing industrial CO2 + renewable H2; Route B: biomass gasification / syngas'),('Prepared by','Mridun Gupta | J24IMT624'),('Institution / course','Institute of Chemical Technology, Mumbai Marathwada Campus, Jalna | Integrated M.Tech Chemical Technology'),('Document number','ENERGY008-REP-001'),('Revision / date','Rev 1.0 / 02 November 2026'),('Engineering basis','Rev 0.1-DRAFT; G3 design basis not frozen'),('Submission status','Consolidated academic report; physical plant design remains provisional')]
t=doc.add_table(rows=0,cols=2); t.style='Table Grid'; t.alignment=WD_TABLE_ALIGNMENT.CENTER
for i,(a,b) in enumerate(rows):
 c=t.add_row().cells; c[0].text=a; c[1].text=b; set_cell_shading(c[0],NAVY); set_cell_shading(c[1], 'EEF3F8' if i%2==0 else 'F7F9FB')
 for ci,cell in enumerate(c):
  set_cell_margins(cell,top=95,bottom=95)
  for pp in cell.paragraphs:
   pp.paragraph_format.space_after=Pt(0)
   for run in pp.runs: set_run_font(run,size=9.5,color=WHITE if ci==0 else DARK,bold=(ci==0))
p=doc.add_paragraph(); p.alignment=WD_ALIGN_PARAGRAPH.CENTER; p.paragraph_format.space_before=Pt(25)
r=p.add_run('PRELIMINARY ACADEMIC DESIGN EXERCISE'); set_run_font(r,size=11,color='C00000',bold=True)
p=doc.add_paragraph(); p.alignment=WD_ALIGN_PARAGRAPH.CENTER
r=p.add_run('Not certified for construction, procurement, commissioning, statutory submission or plant operation.'); set_run_font(r,size=9,color='666666',italic=True)
add_page_break(doc)

# ---- DOCUMENT CONTROL ----
add_heading(doc,'Document Control and Engineering Basis',1,bookmark='DocControl')
add_back_link(doc)
add_para(doc,'This report consolidates the original ENERGY ASSIGNMENT 008 and the available project outputs from Prompts 1–23. It preserves the assignment topics in their original numerical order. The CPS-01 document was inspected only as a visual/structural reference; none of its equipment values, equations, thermodynamic conclusions or design results are used in this report.',size=10.5)
add_table(doc,['Control item','Entry'],[
('Document ID / revision','ENERGY008-REP-001 / Rev 1.0'),('Issue date','02-Nov-2026'),('Governing assignment','PSLassignment2.pdf, ENERGY ASSIGNMENT 008, 5 pages, 27 numbered topics'),('Engineering model version','ENERGY008-MODEL-0.1.0 / RXN-0.1.0 / DATA-0.1.0'),('Design basis version','ENERGY008-Design_Basis.xlsx Rev 0.1-DRAFT; G3 not frozen'),('Working route','Route C, biogenic CO2 + renewable electrolytic H2; ALK reference; PEM flexibility comparator'),('Source evidence cut-off','31-Oct-2026 for literature register; engineering results dated through 02-Nov-2026'),('Document status','Final consolidated academic report; not an approved plant design'),('Prepared / checked / approved','Prepared: Mridun Gupta; Checked: not assigned; Approved: not assigned')], 'Table 1. Document control and issue record', 'Units: identifier/date/status as shown.')
add_callout(doc,'Engineering-use restriction','All quantitative results are classified by evidence status. SCREENING ONLY, BLOCKED, NOT RUN, FAIL and TBD labels are retained. A calculation in this report is not automatically an equipment rating, operating limit, vendor guarantee, regulatory approval or validated process prediction.',AMBER)
add_sub(doc,'Evidence-status definitions')
add_table(doc,['Status','Meaning in this report'],[
('CALCULATED / REFERENCE ONLY','Arithmetic result from declared ideal stoichiometry, standard-state data or a bounded equation. Does not imply physical plant performance.'),('SCREENING ONLY','A numerical result from simplified equations or explicit assumptions; not validated for plant operation or procurement.'),('BLOCKED','The result cannot be calculated credibly because required physical input, property parameters, validated model or vendor/site data are missing.'),('NOT RUN','A required software runtime, GUI, integration, hardware or formal study was not executed.'),('FAIL','An assignment acceptance requirement is demonstrably unmet at the stated audit layer.'),('TBD / OPEN','A controlled design input or acceptance limit is unresolved.')], 'Table 2. Result-status vocabulary', 'Units: not applicable.')
add_sub(doc,'Design basis status and route gate')
add_para(doc,'Route C is retained as the working academic route, not as an approved final route selection. The design basis remains Rev 0.1-DRAFT and Gate 3 is not frozen. The site is not selected. The draft 50 t/day methanol component-equivalent basis is used for ideal hand calculations; the equipment case ladder separately defines 25 t/day minimum stable, 50 t/day normal, 55 t/day maximum continuous and 60.5 t/day process-design capacity. These are design-screening points, not guaranteed capacities or approved operating limits.')
add_para(doc,'The report does not turn a missing value into zero. In particular, physical stream flow/composition/state fields in the 55-row stream register are blank by design. The recycle S-209, purge S-207 and separator flash split remain BLOCKED_NOT_CALCULATED. The ideal reference case is not a full flowsheet simulation.')
add_page_break(doc)

# ---- EXEC SUMMARY ----
add_heading(doc,'Executive Summary',1,bookmark='ExecutiveSummary'); add_back_link(doc)
add_para(doc,'ENERGY-008 investigates a modular green-methanol synthesis concept centred on CO2 hydrogenation using biogenic CO2 and renewable electrolytic hydrogen. Alkaline electrolysis is the reference hydrogen-supply concept; PEM is retained as a flexibility comparator. The report integrates the available design basis, route research, reaction stoichiometry, hand calculations, conceptual process drawings, preliminary equipment data sheets, automation architecture, safety/environmental screening, sensitivity work and software verification evidence.')
add_para(doc,'The project evidence is substantial but does not establish a validated plant design. The most defensible quantitative result is an ideal stoichiometric reference at 50,000 kg/day methanol component-equivalent. At this basis, the minimum theoretical inputs are 68.675 t/day CO2 and 9.437 t/day H2; stoichiometric electrolysis feedwater is 84.336 t/day and theoretical oxygen coproduct is 74.899 t/day. Reaction water formed is 28.112 t/day. These values assume 100% stoichiometric conversion in the reference reaction block and exclude recycle, purge, losses, impurity removal, upstream recovery and product separation.')
add_table(doc,['Result','Value','Evidence boundary'],[
('Methanol component-equivalent basis','50,000 kg/day','Illustrative component basis; not approved nameplate capacity'),('CO2 stoichiometric minimum','68.6749 t/day','Ideal reaction lower bound'),('H2 stoichiometric minimum','9.43708 t/day','Ideal reaction lower bound'),('Electrolyser DI water stoichiometry','84.3362 t/day','Pure stoichiometric feedwater; excludes treatment reject and cooling'),('Theoretical O2 coproduct','74.8991 t/day','Not guaranteed saleable oxygen'),('Reaction water generated','28.1121 t/day','Phase and recovery not solved'),('R-01 standard-state enthalpy rate','-205.699 GJ/day','Thermochemical identity only; not reactor cooling duty'),('E-01 thermoneutral enthalpy equivalent','1,338.076 GJ/day','Not electrolyser system electricity'),('CO2 ideal-gas sensible example','168.854 kW','Pure ideal-gas CO2, 298.15 to 523.15 K'),('Illustrative HX area','56.285 m2','Assumed U=100 W/m2/K, LMTD=30 K, F=1'),('W-201 pump shaft example','0.684 kW','Assumed 50 m head and 70% pump efficiency')], 'Table 3. Consolidated numerical reference results', 'Units shown in result labels; values are not plant guarantees.')
add_para(doc,'The high-pressure synthesis loop remains a major model-validity risk. The draft synthesis pressure is 7 MPa(a) (70 bar(a)), while the identified Graaf et al. kinetic data extend to about 50 bar and the Vanden Bussche/Froment model to about 51 bar. The existing rate expressions are therefore not validated at the draft 70 bar(a) point. A complete high-pressure mixture EOS, binary interaction parameter set, phase-stability check and methanol-water VLE package are also absent. No physical reactor conversion, recycle/purge convergence or distillation performance is reported.')
add_para(doc,'The updated Prompt 22 programme contains 12 OAT sensitivity studies and a deterministic 1,000-point, eight-variable Latin Hypercube proxy screen. It estimates conditional ranges for electrolyser-only electricity, electricity-only variable cost, electricity-related emissions and water scenarios. It does not run the MATLAB engine or optimise the physical process. No safe or feasible plant operating window is recommended. Route A is comparable only on the common ideal CO2/H2 reaction core; Route B remains blocked, so the assignment requirement for two fully evaluated alternatives is not achieved.')
add_para(doc,'The verification record includes static source/configuration checks and independent Python arithmetic. Prompt 21 recorded 82 curated test-register entries: 40 PASS, 2 FAIL, 14 BLOCKED, 19 NOT RUN and 7 SCREENING ONLY. A separate Python audit recorded 115 assertions: 80 PASS, 27 SCREENING ONLY, 2 FAIL, 1 BLOCKED and 5 NOT RUN. Prompt 23 subsequently delivered a staged Python migration with 23 actual pytest tests passing, six CLI run directories and 18 numeric parity rows checked against the independent hand-calculation fixture. MATLAB and GNU Octave were unavailable; MATLAB runtime, GUI runtime and MATLAB/Python parity remain NOT RUN.')
add_callout(doc,'Recommendation','Retain Route C as a working academic reference only. Do not publish an operating window, selected optimum, full CAPEX/OPEX, plant SEC, plant energy/exergy efficiency or green-methanol certification claim until the route, G3 basis, kinetic/property models, physical balances, vendor/site data and required validation evidence are closed.',AMBER)

# ---- DESIGN BASIS ----
add_heading(doc,'Design Basis and Process Boundary',1,bookmark='DesignBasis'); add_back_link(doc)
add_para(doc,'The conceptual process boundary begins at the CO2-rich feed battery limit and raw-water battery limit and includes CO2 conditioning/compression, water treatment, ALK electrolysis, hydrogen drying/compression, synthesis feed mixing, heat recovery candidate, reactor, effluent cooling/separation, recycle/purge, crude-methanol degassing, distillation, product storage, off-gas, wastewater, solids and utility interfaces. The product dispatch boundary is the methanol storage/loading interface. Route A changes the carbon-source/capture front end; Route B changes the feed preparation and gasification/cleanup front end and has a different reaction network.')
add_table(doc,['Basis variable','Working value / definition','Classification / caveat'],[
('Route','Route C: biogenic CO2 + renewable electrolytic H2','Provisional; G3 not frozen'),('Electrolyser','ALK reference; PEM flexibility case','Technology comparison, not vendor selection'),('Normal methanol basis','50 t/day component-equivalent','Illustrative hand-calculation basis'),('Minimum stable / normal / max continuous','25 / 50 / 55 t/day','Draft operating-case ladder; not guaranteed'),('Process design capacity','60.5 t/day','55 t/day × 1.10; do not add the same margin twice'),('Annual availability basis','300 days/year for annualisation','Scenario assumption; not approved uptime'),('Synthesis reference pressure','7 MPa(a), with broad 5–10 MPa(a) context','Screening assumption; kinetic data mismatch at 70 bar(a)'),('Synthesis reference temperature','250 °C, broad 200–300 °C context','Screening assumption; not design metal temperature or trip setpoint'),('ALK H2 outlet interface','20 bar(a) nominal; 15–30 bar(a) sensitivity','Draft interface, vendor map absent'),('CO2 dry purity target','≥99.5 mol%','Assumed screening target; source assay absent'),('H2 dry purity target','≥99.9 mol%','Assumed screening target; OEM guarantee absent'),('Fresh H2:CO2 ratio','3:1 molar','Stoichiometric minimum only; recycle composition unknown'),('Electricity screen','55 kWh/kg H2 system SEC','DOE reference/status scenario; not OEM guarantee'),('Electricity tariff','₹5/kWh','Assumption for electricity-only screen'),('Electricity CI','0.40 kg CO2e/kWh','Assumption for electricity-related emissions only'),('Total water intensity','50 L/kg H2','Scenario midpoint of 30–70 L/kg H2; includes feedstock plus cooling')], 'Table 4. Design-basis inputs and assumption status', 'Units are shown alongside each parameter.')
add_para(doc,'A crucial capacity distinction is maintained throughout. The 50 t/day basis in the independent hand calculation is a component-equivalent reference. The equipment screening ladder uses a 60.5 t/day process-design throughput derived from a 55 t/day maximum continuous case with a 10% flow margin. Values from these two layers are never mixed without an explicit scaling statement.')

# ---- TOC placeholder ----
add_page_break(doc)
add_heading(doc,'Table of Contents',1,bookmark='Contents')
add_para(doc,'Page numbers reflect the final rendered Rev 1.0 report; select a topic or appendix title to navigate.',size=9,color='666666')
TOC_ROWS=[]
toc_titles=[
(1,'Assignment Purpose','topic01'),(2,'Core Problem Statement','topic02'),(3,'Project-Specific Technical Scope','topic03'),(4,'Engineering Inputs and Data','topic04'),(5,'Governing Equations and Model Formulation','topic05'),(6,'Numerical Algorithm','topic06'),(7,'Material Balances','topic07'),(8,'Energy Balance and Thermal Design','topic08'),(9,'Entropy Balance','topic09'),(10,'Exergy Balance','topic10'),(11,'Detailed Equipment Selection and Design Calculations','topic11'),(12,'PFD and P&ID-Level Definition','topic12'),(13,'Industrial Process Automation and Control','topic13'),(14,'PLC/DCS, HMI, Sequencing and Alarm Requirements','topic14'),(15,'Utilities, Environment and Waste','topic15'),(16,'CAPEX Screening','topic16'),(17,'OPEX Screening','topic17'),(18,'Sensitivity Analysis','topic18'),(19,'Flowchart Requirements','topic19'),(20,'MATLAB Modular Architecture','topic20'),(21,'GUI Requirements','topic21'),(22,'Variable Dictionary and Units','topic22'),(23,'Verification and Validation','topic23'),(24,'Python/Open-Source Migration Requirements','topic24'),(25,'Technical Report Structure','topic25'),(26,'Final Submission Package','topic26'),(27,'Acceptance Checklist','topic27'),('A','Worked Calculations','appA'),('B','Equipment Datasheets (28 items)','appB'),('C','Sensitivity and Optimisation Figures','appC'),('D','Automation and Safety Evidence','appD'),('E','Open Decisions and Limitations','appE'),('F','References and Source Provenance','appF')]
for code,title,anchor in toc_titles:
 p=doc.add_paragraph(); p.paragraph_format.space_after=Pt(1); p.paragraph_format.line_spacing=1.0
 p.paragraph_format.tab_stops.add_tab_stop(Inches(6.55),WD_TAB_ALIGNMENT.RIGHT,WD_TAB_LEADER.DOTS)
 add_internal_hyperlink(p,anchor,f'{code}. {title}',size=8.8)
 p.add_run('\tXXX')
 for r in p.runs:
  set_run_font(r,size=8.8,color='333333')
 TOC_ROWS.append({'title':f'{code}. {title}','anchor':anchor})
add_page_break(doc)

# ---- Figure / table lists placeholders ----
add_heading(doc,'List of Figures',1,bookmark='ListFigures')
add_para(doc,'Figure captions state the plotted variables/units and the evidence status. Figures marked BLOCKED or SCREENING ONLY must not be interpreted as measured plant performance.',size=9,color='666666')
FIG_LIST_PARA=[]
# filled later after all figures defined; placeholder pages reserved
add_para(doc,'Figure list page entries are updated from the final rendered document.',size=9,color='666666')
add_page_break(doc)
add_heading(doc,'List of Tables',1,bookmark='ListTables')
add_para(doc,'Table captions identify the units and the evidence boundary. Blank cells and TBD entries are intentional data gaps.',size=9,color='666666')
add_para(doc,'Table list page entries are updated from the final rendered document.',size=9,color='666666')
add_page_break(doc)

# ---- NOMENCLATURE ----
add_heading(doc,'Nomenclature and Units',1,bookmark='Nomenclature'); add_back_link(doc)
add_table(doc,['Symbol / tag','Meaning','SI unit / reporting unit','Notes'],[
('ṁ, ṁᵢ','Mass / component mass flow','kg/s, kg/h, t/day','Use one consistent time basis per balance'),('ṅ, nᵢ','Molar/component molar flow','mol/s, kmol/h, kmol/day','Convert explicitly with molecular weight'),('ξ','Reaction extent rate','kmol/day or mol/s','Reaction-vector convention'),('Q̇','Heat-transfer rate','W or kW','Positive sign defined by control-volume convention'),('Ẇ','Shaft/electrical work rate','W or kW','Declare work input/output direction'),('T, P','Temperature, pressure','K/°C; Pa/bar(a)','Absolute pressure for EOS/compression'),('ρ, μ, Cp','Density, viscosity, heat capacity','kg/m³; Pa·s; J/(kg·K)','Property source and validity must be stated'),('A, V, D, H','Area, volume, diameter, head','m², m³, m, m','Equipment calculation variables'),('U, ΔTLM, F','Overall heat-transfer coefficient, log-mean temperature difference, correction factor','W/(m²·K), K, dimensionless','Service-specific data needed'),('Ṡ, Sgen','Entropy flow/generation rate','W/K','Sign convention and reference states'),('Eẋ, ED','Exergy rate / destruction','W','Reference environment required'),('ηp, ηis, ηm','Pump, isentropic, motor efficiencies','Dimensionless','Assumptions unless vendor-guaranteed'),('PV / MV / SP','Process variable / manipulated variable / setpoint','Tag-dependent','Loop register defines span and action'),('EOS / VLE / PFR','Equation of state / vapour-liquid equilibrium / plug-flow reactor','Not applicable','Model validity is project-specific'),('BPCS / SIS / FGS / ESD','Basic process control / safety instrumented system / fire and gas system / emergency shutdown','Not applicable','Functional safety allocation not complete')], 'Table 5. Nomenclature and reporting units', 'Units are specified in the third column.')
add_para(doc,'Unit convention: pressure values are absolute unless explicitly labelled gauge. Thermodynamic reference temperatures are in kelvin. Mass rates are shown in kg/day, kg/h or t/day only where labelled. Electricity intensity is reported in kWh/kg methanol or kWh/kg hydrogen with the system boundary stated. All stream and equipment values that have not been calculated remain null/TBD, not zero.')

# ---- TOPIC 1 ----
add_topic_heading(doc,1,'Assignment Purpose')
add_para(doc,'The assignment purpose is to develop a modular engineering model for green methanol synthesis with emphasis on utility integration and energy KPIs. The required model links product quality, throughput, equipment sizing, utilities, economics and industrial automation, and demonstrates reproducible calculations and an evaluation of feasible operating conditions.')
add_para(doc,'The model architecture is split into data contracts, pure-component/reference properties, reaction network, balance ledgers, equipment screens, utilities, automation, economics, sensitivity, validation and reporting. The report is an evidence-controlled synthesis of those components. Only the ideal reaction-block reference and selected screening equations currently produce numerical values.')
add_table(doc,['Model domain','Current deliverable','Current evidence level'],[
('Product / quality','Target ≥99.85 wt% methanol used as an academic screening requirement; actual crude/product assay not solved','Target assumption; product quality BLOCKED'),('Throughput / capacity','25 / 50 / 55 / 60.5 t/day ladder; 45/50/55 t/day hand-calculation/sensitivity points','SCREENING ONLY'),('Equipment','28 equipment/package datasheets and sizing register','Mostly BLOCKED; selected flow/power examples SCREENING ONLY'),('Utilities','10 utility service interfaces; electrolyser-only energy and water scenarios','Partial SCREENING ONLY; plant utility rates BLOCKED'),('Economics','Electricity-only cost contribution; CAPEX/OPEX templates','Full CAPEX/OPEX BLOCKED'),('Automation','88 proposed loop/function rows, alarms, cause/effect, modes and sequence concepts','Conceptual; runtime NOT RUN'),('Reproducibility','Frozen stoichiometric fixture, source manifests, Python package and test logs','Python 23 tests PASS; MATLAB NOT RUN')], 'Table 6. Scope-to-model mapping', 'Units in the text/column labels; status describes evidence maturity.')

# ---- TOPIC 2 ----
add_topic_heading(doc,2,'Core Problem Statement')
add_para(doc,'The process problem is to convert feed and design-basis assumptions into product/waste flows, operating conditions, equipment duties and dimensions, utility requirements, preliminary costs and a control philosophy. The assignment also requires a base case, at least two alternatives and an operating-window recommendation.')
add_sub(doc,'Route C working case')
add_para(doc,'Route C uses biogenic CO2 and renewable electrolytic H2; ALK is the reference electrolyser, while PEM is considered for dynamic flexibility. The common synthesis core is CO2 hydrogenation to methanol with water as a coproduct, with reverse water-gas shift represented as a competing reaction pathway. The primary carbon source is only an archetype; no biogas-upgrading site, source assay or chain-of-custody package is selected.')
add_sub(doc,'Alternative cases and acceptance status')
add_table(doc,['Case','Carbon / hydrogen supply','What can currently be compared','Status'],[
('Route C - base','Biogenic CO2 + renewable electrolytic H2; ALK reference','Ideal CO2/H2 stoichiometric core, ALK energy scenario and selected screening anchors','Working route; provisional'),('Route A - alternative 1','Existing industrial CO2 + renewable electrolytic H2','Only the common downstream ideal CO2/H2 reaction core; capture, source carbon origin, conditioning and upstream emissions unknown','Partial common-core comparison only'),('Route B - alternative 2','Sustainable biomass residues -> gasification/cleanup -> syngas-to-methanol','No physical material/energy/economic comparison: biomass assay, gasifier yield, syngas composition, tar/char and cleanup unknown','BLOCKED')], 'Table 7. Route and alternative-case comparison', 'Units: not applicable; route evidence status shown.')
add_callout(doc,'Acceptance finding','The assignment minimum of a base case plus two evaluated alternatives is not met. Route B is not an evaluated alternative, and Route A has only a shared downstream reference-core comparison. No route ranking is justified.',AMBER)
add_para(doc,'No operating window can be recommended from the available evidence. The draft envelope (25–55 t/day, 7 MPa(a), 250 °C nominal) is a screening reference only. The LHS Pareto screen is a two-objective electricity-only proxy, not a physical plant optimisation or operating envelope.')

# ---- TOPIC 3 ----
add_topic_heading(doc,3,'Project-Specific Technical Scope')
add_para(doc,'The working battery limits include CO2 receipt/conditioning, water treatment, ALK electrolysis, hydrogen drying/compression/buffer, mixing and heat recovery, synthesis, cooling/condensation, high-pressure separation, recycle/purge, crude-liquid degassing, methanol-water purification, product storage, off-gas treatment, wastewater, solid waste and utility interfaces. The process description and PFD carry 28 equipment/package tags, 55 material-stream IDs and 10 utility interfaces.')
add_sub(doc,'Operating cases and transient states')
add_table(doc,['Case / mode','Definition in project records','Evidence / status'],[
('Steady normal','50 t/day methanol component-equivalent reference; 7 MPa(a), 250 °C synthesis point','Ideal reference basis only; physical steady-state solution BLOCKED'),('Turndown','25 t/day minimum-stable screening point','Stoichiometric/Python scaling available; equipment/control turndown unvalidated'),('Maximum continuous','55 t/day screening point','Capacity ladder only; not vendor-verified'),('Process-design flow','60.5 t/day = 55 t/day × 1.10','Flow margin included in equipment basis; not nameplate capacity'),('Start-up / shutdown','S00–S110 conceptual states and controlled-shutdown narrative','Logic design input only; not operating procedure'),('Renewable power disturbance','50% of nominal available power for 2 h','Static scenario; dynamic response, storage and buffer sizing not solved'),('Equipment / sensor / utility faults','CO2 loss/off-spec, H2 trip, cooling loss, compressor trip, power/air/comms loss, off-spec product','Disturbance response matrix is qualitative; no dynamic simulation')], 'Table 8. Operating and disturbance case register', 'Units embedded in case definitions; timings are qualitative unless specified.')
add_para(doc,'The disturbance matrix includes 14 principal disturbance/failure cases. The renewable power case is quantified as a static design-input assumption only. Other disturbances are described by PV/signals, proposed automatic response, operator action, response-time scale, expected impact and restart conditions. No field fault injection or sequence execution evidence is available.')

# ---- TOPIC 4 ----
add_topic_heading(doc,4,'Engineering Inputs and Data')
add_para(doc,'The design-basis workbook separates sourced reference values, assumed screening inputs, vendor-required data and open site decisions. The source register contains 74 records spanning kinetics, catalyst stability, reactor/process reviews, electrolyser data, water use, standards, Indian regulatory instruments and thermodynamic/property references. Research retrieval cut-off: 31 October 2026.')
add_sub(doc,'Critical data gaps')
add_table(doc,['Input/model gap','Evidence found','Engineering consequence'],[
('Kinetic pressure validity','Graaf et al. data approximately 15–50 bar; Vanden Bussche/Froment data up to approximately 51 bar','Draft 7 MPa(a) = 70 bar(a) lies beyond cited data range; rate-model extrapolation is not validated [SRC-005, SRC-006]'),('High-pressure mixture EOS','NIST/JANAF pure-species references and IAPWS water/steam data are available; complete PR78 kij, phase stability and residual enthalpy not validated','No quantitative 7 MPa mixture flash, reactor thermodynamics or high-pressure stream enthalpy'),('Methanol-water VLE','No fitted and independently validated Wilson/NRTL parameter set at selected pressure','No column separation, reflux, stage count, product assay or reboiler/condenser duties'),('Electrolyser performance','ALK literature/system scenarios; no vendor polarization, BOP, ramp, purity, degradation or warranty maps','No guaranteed H2 production, electrical load, stack heat, turndown or buffer sizing'),('CO2/H2 feed assays','No supplier/source laboratory assays, trace impurities or contaminant acceptance guarantees','Conditioning, guard-bed design, catalyst protection and recovery remain blocked'),('Water balance boundary','MNRE 18–20 L/kg H2; NITI Aayog 18–25 L/kg; PNGRB case study 59–95 kg/kg with different boundaries [SRC-024–SRC-026]','Do not average; split feedwater, cooling makeup, reject, blowdown, reuse and net withdrawal'),('Site/utility/economic data','No site, utility supply/return conditions, tariff/PPA, waste tariffs, installed cost or quotations','Utilities, emissions, CAPEX and full OPEX remain blocked')], 'Table 9. Critical data gaps and effects', 'Units and ranges are given in the evidence column; status is qualitative.')
add_para(doc,'The draft product target is at least 99.85 wt% methanol in the route/sensitivity records. It is not calculated by the process model. BIS lists IS 517:2020 (Third Revision) with two amendments and voluntary certification; the current full text and any purchaser contract must be checked before freezing grade. The Methanol Quality Control Order 2019 was reported withdrawn effective 23 July 2025 in the research review [SRC-046, SRC-047, SRC-048].')
add_para(doc,'MNRE Green Methanol Standard dated 27 February 2026 is recorded as requiring Green Hydrogen and allowing CO2 from biogenic sources, direct air capture or existing industrial sources, with a ceiling of 0.44 kg CO2e/kg methanol for non-biogenic emissions from the defined stages, averaged over the preceding 12 months. Detailed methanol MRV procedures were not confirmed in the source review; no certification claim is made [SRC-001].')

# ---- TOPIC 5 ----
add_topic_heading(doc,5,'Governing Equations and Model Formulation')
add_para(doc,'The current numerical reference model contains the three-reaction matrix: methanol synthesis (R-01), reverse water-gas shift (R-02) and alkaline water electrolysis (E-01). R-02 is assigned zero extent only in the ideal limiting stoichiometric fixture; this is not a prediction that RWGS is absent. The physical reactor model is planned as a pseudo-homogeneous non-isothermal packed-bed PFR, but catalyst-matched kinetics and pressure-range validation are unresolved.')
add_sub(doc,'Reaction equations and stoichiometric basis')
add_math_equation(doc,'R-01: CO2 + 3 H2 <=> CH3OH + H2O')
add_math_equation(doc,'R-02: CO2 + H2 <=> CO + H2O')
add_math_equation(doc,'E-01: 2 H2O -> 2 H2 + O2')
add_math_equation(doc,'dF_i/dW_cat = sum_j (nu_i,j * r_j)')
add_para(doc,'The reaction vectors and species molecular weights are stored in the controlled reaction/property data. The reaction extent is calculated from the methanol component-equivalent target for R-01. R-02 and physical side reactions remain model variables only when their validated kinetics and operating state are provided.')
add_sub(doc,'Balance and design equations')
add_math_equation(doc,'Overall mass: sum(m_dot_in) - sum(m_dot_out) = dM_CV/dt')
add_math_equation(doc,'Component i: sum(m_dot_i,in) - sum(m_dot_i,out) = dM_i,CV/dt')
add_math_equation(doc,'Q_dot_sensible = m_dot * Cp * (T_out - T_in)')
add_math_equation(doc,'Q_dot = U * A * F * DeltaT_LM;  A = abs(Q_dot)/(U * F * DeltaT_LM)')
add_math_equation(doc,'P_shaft = rho * g * Qv * H / eta_p')
add_math_equation(doc,'Sgen_dot = sum(S_dot_out) - sum(S_dot_in) - sum(Q_dot_k/T_k) >= 0')
add_math_equation(doc,'E_D_dot = T0 * Sgen_dot')
add_math_equation(doc,'A = Q_dot/(U * F * DeltaT_LM);  V_working = Qv * tau')
add_para(doc,'For a full non-isothermal process, the energy equation must use enthalpy rates, shaft/electrical work and boundary heat. The entropy equation uses heat into the control volume as positive in the boundary term; the sign convention and all heat-transfer boundary temperatures must be declared per control volume. The exergy balance requires a defined dead state and physical/chemical/electrical exergy basis. These equations are included as model requirements, not evidence that the corresponding plant quantities have been solved.')
add_sub(doc,'Property and kinetic validity')
add_para(doc,'Pure-component ideal-gas Cp correlations are used only within their stated NIST/JANAF intervals. The CO2 Shomate example is valid from 298 to 1200 K, and the methanol latent-heat reference uses the NIST correlation within its stated interval. Neither pure-fluid correlation replaces a 7 MPa multicomponent EOS. The missing active binary interaction parameters for PR78 remain null, not zero. Methanol-water VLE parameters are not fitted. Kinetic extrapolation above approximately 50–51 bar is not validated [SRC-005, SRC-006, SRC-027–SRC-034].')

# ---- TOPIC 6 ----
add_topic_heading(doc,6,'Numerical Algorithm')
add_para(doc,'The planned numerical sequence is: validate input schemas and units; check positive flows/composition totals; load versioned properties/reactions; calculate reaction or process-component flows; solve physical process steps in flow order; iterate recycle loops to a residual tolerance; calculate energy/entropy/exergy; size equipment against normal, turndown and upset cases; calculate utilities/economics/KPIs; run sensitivity/optimisation; export traces, plots and tests.')
add_para(doc,'The actual Python migration executes a bounded reaction-reference path, not a physical solver. The MATLAB engine has source modules and a solver architecture but no MATLAB/Octave runtime run log. Physical recycle convergence is BLOCKED because separator flash, inerts, full stream compositions, purge criterion and compressor curve are unavailable. A generic scalar fixed-point convergence primitive is synthetic-only and must not be presented as S-209 convergence.')
add_figure(doc,ASSET/'ENERGY008_Solver_Flowchart.png','Numerical solver and fail-closed calculation flow','Units: diagram; no runtime solver trace is implied.')
add_para(doc,'Figure 1 is a source flowchart. It describes intended input checks, model branches, convergence decisions and output statuses. It is not a captured execution trace of the complete flowsheet.')

# ---- TOPIC 7 ----
add_topic_heading(doc,7,'Material Balances')
add_para(doc,'The stream register contains 55 stream IDs, including feed, intermediate, recycle, purge, condensate, off-gas, product, wastewater and solid-waste streams. Numeric mass flow, molar flow, volumetric flow, composition, temperature, pressure and enthalpy fields remain blank in the controlled register where the physical state is not solved. This is intentional. The only current closed material ledger is the ideal reaction reference and elemental stoichiometry.')
add_sub(doc,'Ideal reaction-block results')
add_table(doc,['Component / quantity','Molar rate (kmol/day)','Mass rate (kg/day)','Interpretation'],[
('CH3OH target component','1,560.456777','50,000.000','Illustrative component-equivalent basis'),('CO2 consumed','1,560.456777','68,674.923','R-01 ideal lower bound'),('H2 consumed','4,681.370331','9,437.081','R-01 ideal lower bound'),('H2O formed in R-01','1,560.456777','28,112.066','Reaction water; phase split not solved'),('H2O to electrolyser','4,681.370331','84,336.197','Stoichiometric DI feedwater only'),('O2 theoretical coproduct','2,340.685165','74,899.116','Not sale-grade or guaranteed'),('Net H2O consumption','3,120.913554','56,224.131','Electrolysis water less reaction water')], 'Table 10. Ideal Route C reaction-block material ledger', 'Molar rate: kmol/day; mass rate: kg/day.')
add_sub(doc,'Physical stream-table status')
add_table(doc,['Stream IDs','Service / example','Phase at reference point','Flow / T / P / composition status'],[
('S-001 to S-009','Raw CO2 source, condensate, gas conditioning, recovered CO2, reject, compressor feed','Gas/liquid/solid as register defines','BLOCKED_NOT_CALCULATED; no source assay or unit performance'),('S-101 to S-112','Raw water, DI water, treatment reject, wet H2, H2 dryer condensate, H2 feed, O2 coproduct and KOH-related streams','Liquid/gas as register defines','BLOCKED_NOT_CALCULATED; no site water analysis or ELY vendor data'),('S-201 to S-211','Mixed synthesis feed, reactor effluent, purge and recycle, separator liquid','Gas / two-phase / liquid intended','BLOCKED_NOT_CALCULATED; no kinetics, flash or recycle closure'),('S-301 to S-317','Crude liquid, degassing gas, distillation feed/product/bottoms, vents, condensate, wastewater and waste solids','Liquid/gas/solid as service','BLOCKED_NOT_CALCULATED; no VLE, column, waste assays or treatment model')], 'Table 11. Stream register status by process train', 'Units: stream IDs; physical flow units are kg/h, kmol/h, m3/h where populated.')
add_para(doc,'The ideal integrated reaction is CO2 + 2 H2O -> CH3OH + 1.5 O2. C/H/O atom residuals are zero under the declared stoichiometric vectors. A small mass residual of -0.062418 kg/day remains because the source molecular weights are independently rounded. It is retained rather than forcing a false balancing stream. Full 55-stream plant mass closure remains BLOCKED.')
add_figure(doc,ASSET/'ENERGY008_PFD.png','Conceptual process flow diagram (PFD) with feed conditioning, synthesis, recycle/purge, product and waste battery limits','Units: diagram; all numeric flow states are unresolved.')
add_para(doc,'Figure 2 shows the conceptual PFD. Stream IDs and equipment tags are an architecture register, not a solved material balance. In particular S-207 purge and S-209 recycle values are null/BLOCKED_NOT_CALCULATED and must not be set to zero.')

# ---- TOPIC 8 ----
add_topic_heading(doc,8,'Energy Balance and Thermal Design')
add_para(doc,'The available thermal calculations are standard-state reaction enthalpy identities and pure-component/reference duties. No actual equipment duty register entry has a validated flow state, enthalpy inlet/outlet, utility condition or thermal rating. The available values must not be relabelled as reactor cooling, purchased electricity, condenser/reboiler duty or plant energy closure.')
add_table(doc,['Thermal quantity','Value','Boundary / status'],[
('R-01 reaction enthalpy','-131.820 kJ/mol reaction','Standard-state value, 298.15 K reference'),('R-01 enthalpy rate','-205.699 GJ/day','Ideal reaction-extent reference; not R-301 cooling duty'),('E-01 thermoneutral enthalpy','571.660 kJ/mol electrolysis reaction','Thermoneutral reaction enthalpy; not ALK electricity'),('E-01 enthalpy rate','1,338.076 GJ/day','Not purchased electricity or stack thermal duty'),('Net Route C reaction enthalpy identity','+725.670 kJ/mol methanol','Standard-state net thermochemical identity'),('CO2 sensible heating example','168.854 kW','Pure ideal gas, 298.15 -> 523.15 K'),('Pure methanol latent example','677.083 kW','Pure component at 298.15 K; not column duty'),('HX illustrative area','56.285 m2','U=100 W/m2/K; LMTD=30 K; correction factor 1.0, all assumed')], 'Table 12. Energy and heat-transfer reference quantities', 'Units are included in the quantity/result columns.')
add_sub(doc,'Heat integration')
add_para(doc,'HX-301 is the only currently drawn process-process heat-recovery candidate. It is conceptual: hot synthesis reactor effluent S-203 is intended to preheat mixed synthesis feed S-201, giving S-204 and S-202. The actual inlet/outlet temperature-enthalpy profiles are not solved, and the true heat-transfer duty/area/pressure drop remain blank. No second heat-integration match is supported by current stream-state data.')
add_figure(doc,ASSET/'ENERGY008_Heat_Network.png','Conceptual heat-network diagram showing HX-301 as the only current process-process recovery candidate','Units: diagram; no rated thermal duty is available.')
add_figure(doc,ASSET/'ENERGY008_Composite_Curves.png','Composite-curve/pinch screen; numerical hot and cold curves intentionally withheld because stream enthalpies and temperatures are missing','Units: diagram; pinch temperatures and utility targets are not calculable.')
add_para(doc,'The source composite-curve graphic reports the blocked status; it intentionally does not invent a pinch point, minimum approach temperature, hot/cold utility target or heat-recovery target. Recovered heat must be accounted once only in later energy balances.')

# ---- TOPIC 9 ----
add_topic_heading(doc,9,'Entropy Balance')
add_para(doc,'The control-volume entropy balance is stated as:')
add_math_equation(doc,'Sgen_dot = sum(S_dot_out) - sum(S_dot_in) - sum(Q_dot_k/T_k) >= 0')
add_para(doc,'The project hand-calculation report establishes a thermochemical reference state of T0 = 298.15 K and P0 = 0.1 MPa(a), but it is not a site meteorological dead state. The ideal base fixture has no resolved physical stream entropy flows. Liquid methanol and water standard entropy records needed for the current frozen stoichiometric reference are incomplete, and the process stream states, boundary heat terms, work interactions and heat-transfer temperatures are absent.')
add_callout(doc,'Disposition','Plant entropy generation, unit entropy balances and entropy closure are BLOCKED. No numerical Sgen is reported. Negative entropy generation must remain a diagnostic failure, not be clipped to zero.',AMBER)

# ---- TOPIC 10 ----
add_topic_heading(doc,10,'Exergy Balance')
add_para(doc,'The project-level exergy balance is:')
add_math_equation(doc,'Ex_in_dot + Ex_fuel_dot = Ex_product_dot + Ex_waste_dot + E_D_dot')
add_math_equation(doc,'E_D_dot = T0 * Sgen_dot')
add_para(doc,'The current reference state T0 = 298.15 K, P0 = 0.1 MPa(a) is a standard-state convention only. A site-specific dead state and physical/chemical/electrical exergy methodology have not been approved. The stream enthalpy/entropy, chemical exergy, heat/work boundary and physical balance closure are all incomplete. The exergy destruction ranking figure explicitly reports that the candidates are not rankable and that the ED values are intentionally withheld.')
add_figure(doc,ASSET/'editable'/'ENERGY008_Exergy_Destruction_Ranking.png','Exergy destruction candidate register; numerical ranking and ED values intentionally withheld','Units: candidate units and irreversibility mechanisms; no numerical ED data.')
add_para(doc,'Two future improvement hypotheses are retained for the next validated design iteration: (i) recover sensible heat across HX-301 only if validated stream profiles and minimum approach permit; (ii) reduce compression irreversibility through stage/intercooler optimisation after compressor maps and pressure drops are available. No exergy savings or rank order is claimed.')

# ---- TOPIC 11 ----
add_topic_heading(doc,11,'Detailed Equipment Selection and Design Calculations')
add_para(doc,'The equipment register and 28 Markdown datasheets define service, tag, control volume, PFD stream interfaces, phase, normal/design basis, materials and corrosion hold points, utility interfaces, instruments, safeguards and closure items. Most equipment is BLOCKED because physical loads, stream states, vendor data, design pressure/temperature, mechanical codes or relief cases are missing. The full datasheets are reproduced in Appendix B.')
add_table(doc,['Tag / service','Available result','Status'],[
('V-101 / CO2 inlet knockout','No source gas/liquid load, density, vessel size or liquid residence basis','BLOCKED'),('F-101 / filter and guard train','No contaminant load, face velocity, media capacity or differential-pressure criterion','BLOCKED'),('P-101 / CO2 recovery / purification','CO2 lower-bound flow only; recovery technology and assay absent','BLOCKED'),('K-101 / CO2 compressor','CO2 component flow lower bound only; suction state and compressor map absent','BLOCKED'),('W-201 / DI water treatment','Output-flow anchor only; treatment recovery and reject unknown','SCREENING OUTPUT CAPACITY ONLY'),('ELY-201 / ALK electrolyser','Stoichiometric H2/O2 and Faraday charge anchors; vendor stack/AC maps absent','CAPACITY FLOW ANCHOR ONLY'),('D-201 / H2 dryer/purifier','H2 lower-bound throughput only; dewpoint and crossover data absent','BLOCKED'),('K-201 / H2 compressor/buffer','Two-stage ideal-gas/Shomate screen; normal 20->70 bar(a) 271.7 kW input; design scenario 522.2 kW','SCREENING CALCULATION ONLY - NOT RATING'),('HX-301 / feed-effluent recuperator','No real stream duty, LMTD, U, area or pressure drop; candidate service only','BLOCKED - candidate only'),('R-301 / synthesis reactor','PFR model form, but catalyst mass/bed/volume/diameter/length not calculated','BLOCKED'),('E-302 / V-301 / SP-301 / K-301 / PCV-301','No flash, phase split, recycle/purge, inerts, compressor map or valve Cv','BLOCKED'),('T-401 / E-401 / V-401 / E-402','No MeOH-water VLE, column stages/reflux/hydraulics or duties','BLOCKED'),('P-401 / TK-401','Product flow and 8/24/72 h net inventory scenarios only; no tank/pump rating','FLOW / INVENTORY SCENARIOS ONLY'),('U-501 / W-501 / SW-501 / DR-501','No off-gas, wastewater, solid-waste loads or disposal design','BLOCKED')], 'Table 13. Equipment sizing and datasheet status', 'Units: duty/power units given where a numerical screen is available.')
add_para(doc,'The 60.5 t/day design basis in the equipment case ladder gives theoretical lower-bound H2 flow 475.786 kg/h; DI-water guidance 102.770 m3/day (9 L/kg H2); total-water guidance 205.540–228.377 m3/day (18–20 L/kg H2) under the cited MNRE system boundary. These are screening input anchors, not sized utilities or vendor capacities. The K-201 ideal gas compression results are explicitly screening-only and not an equipment rating.')
add_sub(doc,'Independent equipment calculations')
add_para(doc,'HX-301 illustrative area uses the pure ideal-gas CO2 sensible-duty example, not a solved process stream. W-201 pump power uses stoichiometric DI water at assumed density, head and pump efficiency. K-201 uses a two-stage ideal-gas Shomate model with assumed 75% isentropic efficiency and 95% motor efficiency, perfect intercooling to 40 °C; it omits real-gas effects and vendor map limits. Complete calculation trail appears in Appendix A.')

# ---- TOPIC 12 ----
add_topic_heading(doc,12,'PFD and P&ID-Level Definition')
add_para(doc,'The PFD is a conceptual five-train drawing set. It includes CO2 conditioning/compression; water treatment/ALK electrolysis/H2 drying and compression/O2 handling; synthesis mixer, recuperator, reactor, condenser, separator and recycle/purge; crude-liquid letdown and methanol-water distillation; and product storage/off-gas/waste systems. The process boundary uses 28 equipment/package tags, 55 material streams and 10 utility services.')
add_para(doc,'The P&ID-level sketch is a five-sheet conceptual engineering sketch. It identifies proposed isolation/control/check valves, drains/vents, symbolic relief devices, sample points, instrument tags and maintenance boundaries where developed. It is not a complete P&ID, line list, valve list, relief register, instrument index, I/O list or approved isolation procedure. PSV/PVRV symbols are placeholders only; no set pressure, capacity, orifice or discharge destination has been selected.')
# P&ID images
for i in range(1,6):
    pth=PID_RENDER/f'page-{i}.png'
    add_figure(doc,pth,f'P&ID-level sketch sheet {i} of 5: {"CO2 receipt, purification and compression" if i==1 else "water, ALK electrolysis and H2/O2 train" if i==2 else "methanol synthesis, recycle and purge" if i==3 else "crude letdown and methanol-water distillation" if i==4 else "product storage, off-gas and waste systems"}', 'Units: schematic; no line ratings or relief capacities are approved.', width=6.7, pagebreak=True)
add_para(doc,'No generic fail position is assigned. Service-specific valve fail action, relief protection, vent segregation, closed sampling, double isolation and positive isolation must be defined after HAZOP/LOPA and package review. Hydrogen, oxygen, CO-containing synthesis gas, CO2-rich reject, methanol vapour and routine off-gas cannot be joined to common vents/drains without compatibility and dispersion assessment.')

# ---- TOPIC 13 ----
add_topic_heading(doc,13,'Industrial Process Automation and Control')
add_para(doc,'The control philosophy is designed as a PLC/DCS/SCADA-compatible concept. A 88-row proposed loop/function register is supplied in the source workbook. BPCS/DCS regulatory control and package PLC controls are separated from candidate independent protective functions, machinery protection, fire-and-gas and ESD. No safety integrity level is assigned.')
add_table(doc,['Loop / function','PV and sensor','MV / final element','Objective and current limit'],[
('FIC-101','Raw CO2-rich source flow; FT-101','FCV-101 source inlet','Master feed flow; range/SP TBD from approved streams and P-101 capacity'),('LIC-101','V-101 liquid level; LT-101','LCV-101 condensate outlet','Prevent carry-under; vessel capacity and limits TBD'),('LSHH-101','Independent V-101 high-high level switch','XV-101 source ESD valve candidate','Protective candidate; LOPA and independence required'),('AIT-101','CO2, H2S, O2, moisture and source-specific contaminants','Feed permissive / proposed XV-102','Source qualification; numeric acceptance from assay and catalyst supplier'),('PIC-101','K-101 pressure transmitters','Compressor loading / OEM actuator','Maintain package pressure; OEM map and trip values required'),('FIC-201 / AIC-201','DI water flow / conductivity-resistivity','Water pump/valves or ELY permissive','Protect electrolysis water quality/quantity; OEM limits TBD'),('FIC-301 / RATIO-301','Synthesis CO2 and H2 feed flows','Paired feed valves / compressor demand','Maintain fresh-feed stoichiometric ratio under validated recycle model'),('TIC-301','Reactor bed temperatures (multiple axial points)','Cooling duty / feed cutback / bypass candidate','Temperature control; no validated kinetic or thermal limits'),('PIC-301','Synthesis loop pressure','Back-pressure / compressor control','Maintain loop pressure; pressure design and relief basis TBD'),('LIC-301','V-301 level','Liquid outlet valve','Prevent liquid carryover; vessel hydraulics not calculated'),('ASC-301','K-301 corrected flow / suction and discharge conditions','Anti-surge recycle actuator','Requires OEM surge map; K-301 physical flow blocked'),('AIT-401','Methanol/water/product quality analyser','Product transfer permissive / tank hold','Off-spec product hold; buyer specification and validated analyser absent')], 'Table 14. Representative control-loop register extract', 'Sensor spans and setpoints are TBD; tag-specific engineering units are controlled in source workbook.')
add_para(doc,'The complete controlled loop register contains 88 proposed rows across the 28 equipment tags and 55 material streams. It deliberately leaves numeric measurement spans, control setpoints, alarm limits, deadbands, delays and valve fail positions TBD where no stream states, package maps or relief basis is available. The register is conceptual and is not executable PLC/DCS/SIS logic.')

# ---- TOPIC 14 ----
add_topic_heading(doc,14,'PLC/DCS, HMI, Sequencing and Alarm Requirements')
add_para(doc,'The operation-mode matrix distinguishes OFF, MAINTENANCE, MANUAL, AUTOMATIC, START-UP, NORMAL, TURNDOWN, CLEANING/REGENERATION, CONTROLLED SHUTDOWN, EMERGENCY SHUTDOWN, RESTART HOLD, PRODUCT QUALITY HOLD and TRIP INVESTIGATION. Protective action overrides the sequencer; the package PLC retains local OEM control when appropriate; the DCS/BPCS provides regulatory and supervisory sequencing; operator commands cannot defeat independent protective action. A reset clears a latch only after authorised checks and does not restart equipment.')
add_sub(doc,'Conceptual start-up state sequence')
add_table(doc,['State','Purpose / transition guard','Hold / abort condition'],[
('S00 OFF / request','Operator requests PRE-START; check trip/permit/mode history','ESD latch, unknown isolation, unsafe atmosphere or unverified inventory'),('S10 PRE-START','Verify mechanical completion, valve line-up, calibration, package documents and revision consistency','Permit/blind/isolation mismatch or failed critical signal'),('S20 Utilities / protection ready','Confirm electrical, cooling, air, N2, detection, UPS, ESD and relief route readiness','Unavailable essential utility/protection'),('S30 Integrity / inerting hold','Require approved pressure-integrity/leak-test and inerting procedures','No approved procedure or no safe destination'),('S40 Feed conditioning ready','Check filters, separators, DI supply and gas quality','Off-spec source, high filter DP or treatment not ready'),('S50 Catalyst conditioning hold','Require supplier catalyst loading/activation and temperature-management procedure','OEM procedure or safeguards absent'),('S60 H2 / CO2 available','Confirm electrolyser and gas conditioning ready','Crossover, low DI quality, off-spec H2/CO2'),('S70 Recycle loop established','Establish approved loop conditions and anti-surge readiness','No compressor map, no stable recycle state'),('S80 Controlled reactant admission','Sequence flow/ratio demand under approved limits','Loss of ratio, pressure, cooling or temperature permissive'),('S90 Condensation / separator ready','Confirm cooler, separator, level and controlled liquid transfer','Phase/level/utility conditions not met'),('S100 Distillation / quality stabilisation','Establish column, condenser, reflux, reboiler and quality hold','No VLE/column procedure or off-spec product'),('S110 NORMAL / TURNDOWN','Release production control within validated equipment capacity','Any protective trip, off-spec, utility loss or operator hold')], 'Table 15. Conceptual start-up state sequence', 'Times: qualitative; timers and setpoints remain TBD.')
add_para(doc,'The sequence narrative stops at the boundary of missing OEM and safety procedures. No gas introduction, leak-test pressure, inerting endpoint, heat-up rate, pressurisation rate, catalyst activation, hazardous depressurisation or venting instructions are prescribed. The full sequence and state-transition source document is included in Registers and Source_Code handoff.')
add_sub(doc,'Alarm and interlock matrix')
add_table(doc,['Alarm / trip tag','Priority','Cause / basis','Consequence','Proposed response / current status'],[
('LSHH-101','P1','Independent V-101 high-high liquid level; setpoint TBD','Liquid carryover / downstream damage','Candidate XV-101 source isolation; LOPA and independent sensor design required'),('AQT-101','P1','CO2 impurity / moisture outside catalyst acceptance; limit TBD','Catalyst poisoning/corrosion/process upset','Hold feed admission; confirm sample/analyser; limits from source assay/OEM'),('AQL-201','P1','DI water conductivity/resistivity outside ELY OEM specification','Stack degradation/crossover risk','Remove ELY start permissive or controlled OEM ramp-down'),('PAH-201/202','P1','H2/O2 separator high pressure; limit TBD','Overpressure / release','OEM package trip/isolation; pressure boundary and relief coordination open'),('DPAH-201','P1','ELY separator differential pressure high','Diaphragm damage and gas crossover','OEM safety logic de-energises/isolate per package procedure'),('TAH-301','P1/P2 candidate','Reactor temperature high; trip threshold TBD','Thermal excursion / catalyst damage','Cut feed/heat and invoke engineered safe state; kinetics and response not validated'),('PAH-301','P1/P2 candidate','Synthesis loop high pressure','Overpressure / loss of containment','Isolate reactants; mechanical relief protection separately designed'),('VIB-301','P2','Recycle compressor vibration / machinery alert','Mechanical damage / loss of recycle','OEM machinery protection action; compressor maps absent'),('AQH-401','P1','Product off-spec / analyser invalid','Contaminated dispatch','Quality hold, inhibit transfer to dispatch, retain product in identified tank'),('PAH-501','P1/P2 candidate','Off-gas header high backpressure','Upstream pressure rise / unsafe gas accumulation','Limit upstream purge/degassing sources; U-501 design unavailable')], 'Table 16. Representative alarm and candidate interlock matrix', 'Alarm priorities are proposed; numeric limits, deadbands and delays remain TBD.')
add_para(doc,'The source alarm register contains 70 proposed alarm rows with priority, threshold basis, deadband, delay, cause, consequence, operator action, automatic action, acknowledgement/reset and data gaps. The safeguard package contains 29 preliminary cause/effect requirements and 16 safe-state principles; a later detailed interlock cause-and-effect matrix contains 37 proposed entries. These registers have overlapping scope but distinct row structures and are retained separately. None is an approved safety requirements specification or certified safety function.')
add_para(doc,'Disturbance cases include renewable power shortfall, CO2/H2 feed loss, cooling loss, recycle compressor trip/surge approach, sensor/analyser failure, valve failure, instrument-air loss, electrical power loss, communications loss, off-spec methanol, off-gas treatment loss, DI water quality/flow loss, H2/O2 crossover and fire/gas detector escalation. Most logic is qualitative and no dynamic model or hardware/PLC test is reported.')
add_figure(doc,ASSET/'ENERGY008_Automation_State_Diagram.png','Automation state and sequence diagram','Units: logical states / transitions; sequence timing is not validated.')

# ---- TOPIC 15 ----
add_topic_heading(doc,15,'Utilities, Environment and Waste')
add_para(doc,'The utility register carries ten services: U-001/009 electrical power; U-002/003 cooling-water supply/return; U-004/010 steam/hot utility and conditional return; U-005 instrument air; U-006 nitrogen/inert gas; U-007 fuel; U-008 combustion/process air. Supply/return pressures, temperatures, flows, rates, tariff and vendor loads remain uncalculated except for bounded electrolyser/H2 electricity and water scenarios.')
add_table(doc,['Utility / impact','Available number or boundary','Status'],[
('Electrolyser system electricity','55 kWh/kg H2 screen; 21.627 MW at 50 t/day basis','SCREENING ONLY; compressor/auxiliary loads excluded'),('Specific electricity per methanol','10.381 kWh/kg MeOH','Electrolyser H2 system only'),('Electricity-only variable cost','₹51.90/kg MeOH at ₹5/kWh','Assumed tariff; excludes all non-electricity OPEX and CAPEX'),('Electricity-related emissions','4.152 kg CO2e/kg MeOH at 0.40 kg CO2e/kWh','Assumed factor; not full GHG/MRV'),('Stoichiometric DI water','84.336 m3/day approximately','Water feed component only; excludes recovery/reject/cooling'),('Total water scenario','471.85 m3/on-stream day at 50 L/kg H2','Feedstock plus cooling scenario; includes direct electrolysis water'),('Cooling/steam/fuel/air/N2','No quantitative service rates or return states','BLOCKED'),('Wastewater/off-gas/solids','Stream IDs and recovery priorities identified; no physical rates or composition','BLOCKED')], 'Table 17. Utility and environmental screening summary', 'Units are included in the first two columns; total-water scenario includes feedwater.')
add_para(doc,'The 50 L/kg H2 total-water scenario must not be added to 84.336 m3/day stoichiometric DI water: it is a feedstock-plus-cooling total and therefore already includes feedwater. Water source, withdrawal entitlement, raw-water assay, RO/EDI recovery/reject, cooling makeup, evaporation, blowdown, reuse and discharge are open.')
add_sub(doc,'Waste and environmental stream families')
add_table(doc,['Stream family','Potential constituents / source','Required management evidence'],[
('S-002 / S-009 / S-103 / S-105','Source condensate, compression condensate, treatment brine/reject, dryer condensate','Representative assay, segregation, water balance, permitted disposal/reuse'),('S-005 / S-315 / S-312 / S-317','Spent filters/guard media, captured solids, catalyst and fines','Supplier SDS, contaminant loading, waste characterisation, recycling/take-back or authorised TSDF'),('S-007 / S-207 / S-211 / S-306','CO2 reject, purge, degassing gas, column non-condensables','Flow/GC/VOC composition, recovery feasibility, treatment and emission monitoring'),('S-307 / S-308 / S-310','Water-rich column bottoms, treated effluent, sludge','Methanol loss/COD, treatment performance, consent limits, sludge classification'),('S-313 / DR-501','Cleaning, sampling and maintenance drains','Segregated drains, compatibility assessment, LOTO and closed collection')], 'Table 18. Environmental and waste stream register extract', 'Units: stream identifiers; quantities are not available.')
add_para(doc,'Potential Indian statutory review includes EIA Notification 2006 (including item 5(f) screening where applicable), Air and Water Acts and applicable consent conditions, Environment (Protection) Rules, Hazardous and Other Wastes Rules, Solid Waste Management Rules 2026, MSIHC Rules, PESO pressure-vessel rules, groundwater permissions, and Boiler Act 2025 only if an on-site boiler is selected. The applicability matrix depends on final site, process, inventory, discharge, and activity classification. No consent, environmental clearance, PESO approval, statutory classification or code compliance is claimed.')
add_para(doc,'The MNRE Green Methanol Standard’s 0.44 kg CO2e/kg MeOH non-biogenic emissions ceiling is a specific defined-stage / 12-month-average condition, not a full lifecycle factor. The current 4.152 kg CO2e/kg electricity contribution arises from an assumed power factor and excludes capture, equipment, upstream supply, auxiliary loads and other stages. It cannot be compared directly with the regulatory ceiling or used to claim compliance [SRC-001].')

# ---- TOPIC 16 ----
add_topic_heading(doc,16,'CAPEX Screening')
add_para(doc,'The assignment formula is retained as a cost-structure requirement:')
add_math_equation(doc,'CAPEX = sum(C_equipment,i * F_install,i) + C_piping + C_I&C + C_civil + C_engineering + C_contingency')
add_para(doc,'The project cost model workbook is a template, not a priced estimate. No vendor quotations, equipment purchase costs, installed factors, location factors, piping/instrumentation/civil/structural estimate, engineering cost, commissioning cost, contingency basis, currency-year basis or project site are approved. Consequently the complete screening CAPEX is BLOCKED. No CAPEX figure or order-of-magnitude total is invented.')
add_table(doc,['Cost element','Required input','Current status'],[
('Major equipment','Vendor budget quotes, sizes, materials, design pressure/temperature, redundancy','BLOCKED'),('Installation factors','Published factor basis, size/material/complexity and location adjustments','BLOCKED'),('Piping / valves','Line list, metallurgy, diameter, pressure class and routing','BLOCKED'),('Instrumentation and control','I/O, control valves, analyser packages, DCS/PLC/SIS scope','BLOCKED'),('Electrical / civil / structures','Load list, hazardous-area classification, plot plan and foundations','BLOCKED'),('Engineering / commissioning','Project execution strategy and contractor scope','BLOCKED'),('Contingency / escalation','Estimate class, cost index, currency and cost year','BLOCKED')], 'Table 19. CAPEX estimate completeness register', 'Units: currency and year are TBD; no total is estimated.')

# ---- TOPIC 17 ----
add_topic_heading(doc,17,'OPEX Screening')
add_para(doc,'The assignment OPEX structure includes feedstock, utilities, labour, consumables/catalyst/solvent, maintenance, waste treatment, quality testing, packaging, downtime and by-product credits. Full annual OPEX is BLOCKED because feed and utility tariffs, labour, catalyst replacement, maintenance, waste tariffs, water/power PPA and product offtake are not established.')
add_math_equation(doc,'OPEX_annual = C_feed + C_utilities + C_labour + C_consumables + C_maintenance + C_waste - C_byproduct')
add_para(doc,'One partial electricity-only variable-cost contribution is available under the explicit screening assumptions: 55 kWh/kg H2 system SEC, 3 mol H2/mol MeOH, ₹5/kWh, 50 t/day component-equivalent basis and 300 on-stream days/year. This excludes CO2 source recovery, compression, synthesis/recycle, cooling, distillation, water treatment, labour, maintenance, replacement, waste, packaging, finance and CAPEX. It also excludes any oxygen credit.')
add_table(doc,['Derived screening quantity','Value','Calculation basis'],[
('H2 mass ratio','0.188742 kg H2/kg MeOH','3 mol H2 per mol MeOH using declared MW values'),('Electrolyser specific electricity','10.381 kWh/kg MeOH','0.188742 × 55 kWh/kg H2'),('Electrolyser electric load','21.627 MW','50,000 kg/day × 10.381 kWh/kg / 24 h'),('Electricity-only cost','₹51.90/kg MeOH','10.381 kWh/kg × ₹5/kWh'),('Annual methanol component-equivalent','15,000 t/year','50 t/day × 300 operating days'),('Annual electrolyser electricity','155.712 GWh/year','10.381 kWh/kg × 15,000,000 kg/year'),('Annual electricity spend','₹778.6 million/year','155.712 million kWh × ₹5/kWh'),('Electricity-related emissions','4.152 kg CO2e/kg MeOH','10.381 × 0.40 kg CO2e/kWh'),('Annual electricity-related emissions','62,280 t CO2e/year','4.152 kg/kg × 15,000 t/year')], 'Table 20. Electricity-only cost and emissions scenario', 'Units are shown in each row; not full plant OPEX/GHG.')
add_callout(doc,'Boundary warning','The ₹51.90/kg value is not methanol production cost or LCOM. It is only the electrolyser-system electricity contribution under an assumed tariff and system SEC.',AMBER)

# ---- TOPIC 18 ----
add_topic_heading(doc,18,'Sensitivity Analysis')
add_para(doc,'Prompt 22 extends the earlier Prompt 21 sensitivity gap. It contains 12 independent OAT studies and a 1,000-point, eight-variable deterministic Latin Hypercube Sample (seed 20261102). OAT and LHS calculations are closed-form proxy equations, not a run of the MATLAB engine or the physical process model. This satisfies the breadth of the sensitivity exercise at screening tier, but not a validated process optimisation.')
add_table(doc,['Study','Parameter / range','Sensitivity output','Status / limitation'],[
('S01','Throughput: 45 / 50 / 55 t/day','Stoichiometric component rates, ELY MW, annual MeOH/electricity','Linear scaling only'),('S02','ALK SEC: 48 / 52 / 55 kWh/kg H2','Specific electricity, MW, electricity-only cost/emissions','DOE system status/target references; not OEM guarantee'),('S03','Tariff: ₹3 / ₹5 / ₹8 per kWh','Electricity-only cost contribution','Assumed tariff scenarios'),('S04','Electricity CI: 0.05 / 0.40 / 0.80 kg CO2e/kWh','Electricity-related emissions','Assumed power carbon scenarios; not GHG MRV'),('S05','Availability: 80 / 82.19 / 95%','Annual production, electricity and water','Assumed annualisation'),('S06','Fresh H2/CO2: 3.00 / 3.15 / 3.30 mol/mol','Gross H2-equivalent feed and ELY power','No recycle/benefit from excess H2 modelled'),('S07','CO2 dry purity: 99.0 / 99.5 / 100.0 mol%','Conditioned dry gas molar flow','Impurity identity/removal duty absent'),('S08','Total water intensity: 30 / 50 / 70 L/kg H2','Total water demand','Feedstock + cooling, not additive to stoich DI feed'),('S09','HX U: 75 / 100 / 125 W/m2/K','Illustrative exchanger area','Same assumed pure-CO2 reference duty'),('S10','HX LMTD: 20 / 30 / 40 K','Illustrative exchanger area','Same assumed duty and U'),('S11','Pump margin: 0 / 10 / 20%','Design flow capacity','Hydraulic network and vendor curve absent'),('S12','Heat recovery: 0 / 25 / 50%','Recovered/residual share of 168.854 kW example','Not whole-plant heat integration')], 'Table 21. One-at-a-time sensitivity programme', 'Ranges and engineering units shown by parameter.')
add_para(doc,'The central reference screen gives 10.381 kWh/kg MeOH electrolyser-system electricity, 21.627 MW, ₹51.90/kg electricity-only variable cost, and 4.152 kg CO2e/kg electricity-related emissions. The LHS conditional output percentiles are summarized in Table 22. Since inputs are sampled independently and uniformly, P05/P50/P95 are conditional scenario quantiles, not statistical confidence or prediction intervals.')
add_table(doc,['Output','P05','P50','P95','Boundary'],[
('Specific electricity (kWh/kg MeOH)','9.440','10.179','11.037','Electrolyser only'),('Electricity-only cost (₹/kg MeOH)','33.14','55.96','79.78','Variable electricity only'),('Electricity-related emissions (kg CO2e/kg MeOH)','0.878','4.329','7.833','Power emissions only'),('Electrolyser load (MW)','18.679','21.217','23.930','System energy scenario'),('Annual methanol (t/year)','13,936','15,934','17,960','Throughput/availability assumptions'),('Annual electricity (GWh/year)','139.332','162.257','187.285','Electrolyser-system scenario'),('Total water (m3/on-stream day)','315.604','491.296','684.572','Feedstock-plus-cooling scenario')], 'Table 22. Conditional LHS output intervals', 'Units shown in output label; independent uniform sampling.')
add_para(doc,'The sampled two-objective proxy optimisation used electricity-only cost and electricity-related emissions. The lowest electricity-only cost sample was ₹28.50/kg MeOH at 1.407 kg CO2e/kg MeOH; the lowest electricity-emissions sample was 0.489 kg CO2e/kg MeOH at ₹57.49/kg MeOH. These are sample points within the proxy domain, not global optima or a feasible process Pareto front. The sample omitted product purity, reactor temperature/pressure/residence limits, pressure drop, compressor surge, pump NPSH, exchanger duty, power matching, water entitlement, HAZOP limits, CAPEX and full OPEX.')

# Sensitivity charts in appendix C later; selected in main topic
for fn,caption in [('S01_Throughput.png','Throughput OAT: ideal component-equivalent feed and electrolyser load'),('S02_Alkaline_SEC.png','ALK system specific-electricity OAT: electricity-only contribution'),('S03_Electricity_Tariff.png','Electricity tariff OAT: electricity-only cost contribution'),('S04_Electricity_Carbon_Intensity.png','Electricity carbon-intensity OAT: power-related emissions contribution'),('M01_LHS_Pareto.png','LHS proxy Pareto screen: electricity-only cost versus electricity-related emissions')]:
    add_figure(doc,PLOT/fn,caption,'Units: axes carry parameter/output units; SCREENING ONLY, not physical process optimum.')

# ---- TOPIC 19 ----
add_topic_heading(doc,19,'Flowchart Requirements')
add_para(doc,'Three distinct flowcharts are supplied: the top-level process flow, the solver/calculation sequence and the automation state/sequence diagram. They show conceptual inputs, calculation order, branches, convergence checks, alarms/interlocks, safe-state logic and outputs. They are design logic references only; no validated runtime execution trace exists for the complete physical process.')
add_figure(doc,ASSET/'ENERGY008_TopLevel_Flowchart.png','Top-level process flowchart','Units: logical process blocks; equipment values are not represented as measured results.')
add_figure(doc,ASSET/'ENERGY008_Solver_Flowchart.png','Numerical solver and calculation flowchart','Units: logic; physical solver convergence not demonstrated.')
add_figure(doc,ASSET/'ENERGY008_Automation_State_Diagram.png','Automation state and sequence diagram','Units: logical states; response timing and trip settings are not validated.')

# ---- TOPIC 20 ----
add_topic_heading(doc,20,'MATLAB Modular Architecture')
add_para(doc,'The source project contains the assignment-named modular architecture plus additional helper modules. The model/data/solver/GUI/reporting layers are separated; the GUI adapter delegates to a GUI-independent run engine. The static project/configuration review corrected root paths and data manifest assumptions. However MATLAB and GNU Octave were unavailable in the verification environment, so no MATLAB parser, compile, numerical run, UI launch or MATLAB-generated output has been demonstrated.')
add_table(doc,['Assignment module','Role / current status'],[
('input_validation.m','Schema, units, bounds, input completeness and fail-closed status checks; static source available, runtime NOT RUN'),('property_models.m','Pure reference properties and blocked mixture-property paths; runtime NOT RUN'),('material_balance.m','Reaction-reference component / element ledger; physical flowsheet BLOCKED'),('energy_balance.m','Reference enthalpy/duty calculations; plant energy closure BLOCKED'),('entropy_exergy.m','Entropy/exergy interfaces; physical balances BLOCKED'),('equipment_sizing.m','Screening equipment arithmetic and datasheet statuses; most ratings BLOCKED'),('utilities_model.m','Utility interface and screening data; full plant rates BLOCKED'),('control_logic.m','Proposed sequence, loop, interlock and disturbance structures; no executed control simulation'),('economics.m','Formula/template and electricity-only proxy; full CAPEX/OPEX BLOCKED'),('sensitivity_optimisation.m','Reference OAT/screening routines; MATLAB run NOT RUN'),('validation_checks.m','Checks and status gates; MATLAB runtime NOT RUN'),('reporting_plots.m','Plot/table export functions; MATLAB runtime NOT RUN'),('main.m','Startup/preflight entry point in project architecture; GUI engine orchestration occurs via gui_run_engine.m')], 'Table 23. MATLAB module architecture and execution status', 'Units: file/module names; status distinguishes static source from runtime evidence.')
add_para(doc,'Prompt 21 reports 100 static project/source/configuration checks passing and 55 hashed data files verified. Prompt 20 GUI source-contract verification reports 80 checks passing. These are static source/contract checks only and are not evidence of MATLAB runtime numerical correctness.')

# ---- TOPIC 21 ----
add_topic_heading(doc,21,'GUI Requirements')
add_para(doc,'A programmatic MATLAB GUI prototype is present and maps the ten required functional areas (design basis, streams, operating conditions, equipment, balances, utilities, economics, automation, sensitivity and reporting) across 11 UI pages/tabs. Unit-aware input contracts, source-status warnings, run/reset actions and export/plot view requirements are specified in the GUI documentation. The GUI source-contract checker completed 80 static assertions.')
add_para(doc,'No MATLAB GUI was launched. Run/Reset, displayed stream tables, plot refresh, datasheet export, report export, numerical error handling, resize behaviour, App Designer compatibility and actual HMI integration remain NOT RUN. There are no GUI screenshots or exported results from an executed run. The prototype is therefore a source-level prototype only, not a validated user interface.')

# ---- TOPIC 22 ----
add_topic_heading(doc,22,'Variable Dictionary and Units')
add_para(doc,'The controlled dictionary covers mass/component flows, heat rates, temperature/pressure, density/viscosity/heat capacity, area/volume/diameter/head, model factors, entropy/exergy, and PV/MV/SP tags. Units are explicit at module boundaries. Internal Python package calculations use mol/s, kg/s and kg/mol where relevant, with explicit conversion to kg/day and kmol/day at the reporting boundary. Pressure is absolute and temperatures are kelvin internally.')
add_table(doc,['Symbol / parameter','Meaning','Canonical unit','Model rule'],[
('ṁ_i','Mass/component flow','kg/s internally; kg/h or t/day for reporting','Never mix time basis without conversion'),('ṅ_i','Molar/component flow','mol/s internally; kmol/day for reporting','Use molecular weight from property register'),('Q̇','Heat rate','W / kW','Do not assign reference enthalpy rate to equipment duty'),('T / P','Temperature / pressure','K; Pa or MPa(a)','Absolute pressure; T K internally'),('ρ / μ / Cp','Density / viscosity / heat capacity','kg/m3; Pa·s; J/(kg·K)','Source and validity interval required'),('A / V / D / H','Heat-transfer area / volume / diameter / pump head','m2 / m3 / m / m','No equipment dimension unless hydraulic/thermal data support it'),('η / φ / α / β / γ','Efficiency / model factors','Dimensionless or model-defined','Define by model and data source'),('Ṡ / Sgen','Entropy flow / entropy generation','W/K','Sign convention and heat-boundary temperatures required'),('Eẋ / ED','Exergy flow / destruction','W','Dead-state and physical/chemical exergy model required'),('PV / MV / SP','Process variable / manipulated variable / setpoint','Tag-dependent','Numeric spans and limits TBD until process/vendor basis exists')], 'Table 24. Variable dictionary and unit contract', 'Units shown in canonical-unit column.')

# ---- TOPIC 23 ----
add_topic_heading(doc,23,'Verification and Validation')
add_para(doc,'Verification evidence is separated by layer. The Prompt 21 curated test register contains 82 records: 40 PASS, 2 FAIL, 14 BLOCKED, 19 NOT RUN and 7 SCREENING ONLY. A separate independent Python assertion audit contains 115 results: 80 PASS, 27 SCREENING ONLY, 2 FAIL, 1 BLOCKED and 5 NOT RUN. These populations are not merged because they test different evidence layers. The 80 Python PASS checks include static source/data assertions and arithmetic/fail-closed contracts; they do not imply that MATLAB or the plant model passed.')
add_table(doc,['Test evidence set','PASS','FAIL','BLOCKED','NOT RUN','SCREENING ONLY','Interpretation'],[
('Prompt 21 curated test register (82 records)','40','2','14','19','7','Traceability and test-record population'),('Independent Python audit (115 assertions)','80','2','1','5','27','Source, arithmetic and status-contract checks; not MATLAB'),('Prompt 23 Python package tests','23 passed','0 reported','N/A','N/A','N/A','Actual pytest execution on CPython 3.13.5'),('Prompt 19 MATLAB suite','0 executed','N/A','N/A','NOT RUN','N/A','MATLAB/Octave runtime unavailable')], 'Table 25. Verification population summary', 'Counts are records/assertions, not plant operating events.')
add_figure(doc,Path('/mnt/data/energy008_work/verification_status.png'),'Prompt 21 curated verification register status distribution','Units: number of test-register records; this is not a plant KPI.')
add_para(doc,'Independent Python arithmetic checks include reaction atom balance, ideal stoichiometry, standard reaction enthalpy identities, CO2 Shomate sensible heat, pure methanol latent reference, illustrative exchanger area and pump duty, selected dimensional identities and frozen fixture comparisons. The independent comparison report records agreement with the NIST-derived standard-state thermochemical identities and the frozen hand fixture for 18 numeric rows. These checks validate the cited arithmetic boundaries only.')
add_para(doc,'The Python staged migration in Prompt 23 executed 23 tests successfully and six CLI run directories: Route C 50 t/day reference, Route A shared-core reference, Route B blocked, Route C 25 t/day turndown, and two installed CLI smoke runs. Those results are SCREENING ONLY or BLOCKED as appropriate. The actual MATLAB unit suite, MATLAB GUI runtime, hardware/PLC fault tests, physical recycle convergence, plant model validation, and MATLAB/Python runtime parity remain NOT RUN or BLOCKED.')

# ---- TOPIC 24 ----
add_topic_heading(doc,24,'Python/Open-Source Migration Requirements')
add_para(doc,'A staged Python package `energy008-python` version 0.1.0 exists under the Prompt 23 project. The migration preserves the source reaction/property records, units, status semantics, frozen hand fixture and data hashes. Core implemented elements include configuration/schema validation, unit conversion, reaction matrix and ideal material ledger, CO2 Shomate and methanol latent references, standard enthalpy identities, HX/pump screening equations, reference KPIs, throughput sensitivity, JSON/CSV/PNG exports and a CLI.')
add_table(doc,['Migration layer','Implementation / acceptance state'],[
('Packaging / config / manifest','Implemented for bundled JSON subset; root discovery and data hash checks included'),('Unit conversion / reactions','Implemented and tested against declared reaction vectors'),('Material / elemental ledger','Implemented for ideal Route A/C reaction-block reference only'),('Pure properties / energy reference','CO2 Shomate, methanol latent reference and standard enthalpy identities; fixture comparison PASS'),('Equipment / KPI','HX/pump and reference material KPI arithmetic; screening only'),('Entropy/exergy, plant utilities, full economics, environmental KPIs','Blocked-state interfaces only; missing physical inputs retained as null'),('PFR, PR78 EOS, VLE, physical recycle/purge','Not ported as physical models; interfaces remain BLOCKED'),('GUI','No Python GUI implemented; engine is UI-independent'),('Runtime / tests','23 pytest tests passed on CPython 3.13.5; six CLI runs generated'),('MATLAB/Python parity','NOT RUN; no MATLAB outputs exist')], 'Table 26. MATLAB-to-Python migration status', 'Units: versions and test counts as shown.')
add_para(doc,'The declared tested environment is CPython 3.13.5, NumPy 2.3.5, SciPy 1.17.0, pandas 2.2.3, Matplotlib 3.10.8 and pytest 9.0.2. The package lock is a tested Linux/Python 3.13 resolution; Windows/macOS wheels and runtime have not been qualified. CoolProp, Cantera, BioSTEAM, DWSIM, REFPROP and external commercial databases are not bundled. Their licensing/data-access and property coverage limits must be reviewed before selection.')

# ---- TOPIC 25 ----
add_topic_heading(doc,25,'Technical Report Structure')
add_para(doc,'This consolidated report follows the original assignment sequence and begins with the executive summary/design basis, source/standards review, process description, equations and numerical method, equipment calculations/datasheets, balances, automation, utilities/environment/safety, cost/sensitivity, verification, limitations and recommendations. Supporting appendices include the hand calculation trail, all 28 equipment datasheets, sensitivity/optimisation figures, automation/safety references, open decisions and source bibliography.')
add_para(doc,'The 27 topic headings are preserved in the same order and wording as the governing five-page `PSLassignment2.pdf`. Supplemental report front matter does not renumber or replace the assignment topic sequence. The equations are included as editable Word equation objects; all figures/tables are numbered, captioned and referenced in the nearby text. The document includes a clickable static table of contents, figure/table lists, internal topic bookmarks, Back to Contents links and page-number footer.')

# ---- TOPIC 26 ----
add_topic_heading(doc,26,'Final Submission Package')
add_para(doc,'The consolidated submission folder accompanying this report includes the editable Word report, PDF review copy, short slide deck, figure/table registers, bibliography, controlled source registers, diagram source files, the MATLAB project and staged Python project from Prompt 23, and QA records. The archive handoff includes the source files needed to reproduce the bounded reference calculations and the explicit blockers for physical model work.')
add_table(doc,['Package element','Location / format','Status'],[
('Technical report','Report/ENERGY008_Technical_Report.docx and .pdf','Produced in this handoff; PDF rendered from Word source'),('Short presentation','Presentation/ENERGY008_Short_Presentation.pptx','Produced in this handoff'),('Figure / table registers','Report/Figure_Register.csv; Report/Table_Register.csv','Produced from final captions'),('Bibliography','Bibliography/ENERGY008_Bibliography.bib; ENERGY008_Reference_List.csv; source-register workbook','Source IDs, citations and URLs retained'),('Engineering registers','Registers/*.xlsx and supporting .csv/.md','Original design-basis, streams, equipment, loop, alarm, cause/effect, utilities, water, emissions, safety, sensitivity and verification data'),('Editable source diagrams','Source_Diagrams/*.drawio, *.svg, *.dot and PDF sources','Original diagram sources retained'),('MATLAB / GUI source','Source_Code/ENERGY008_MATLAB/','Project source; MATLAB runtime NOT RUN'),('Python migration','Source_Code/ENERGY008_MATLAB/Python/','23 pytest tests passed; partial migration'),('QA / evidence','QA/Render_QA_Report.md, test reports, manifest and figure/table registers','Final handoff evidence')], 'Table 27. Final submission folder manifest', 'Units: not applicable; file formats are specified.')

# ---- TOPIC 27 ----
add_topic_heading(doc,27,'Acceptance Checklist')
add_para(doc,'The checklist below reflects the current report and engineering evidence, not an aspirational design state. A topic can have a document or source file and still remain incomplete at the physical design or runtime-validation level.')
add_table(doc,['Assignment acceptance item','Current disposition','Evidence / remaining gap'],[
('Process boundary, design basis and assumptions explicit','PARTIAL','Conceptual boundary and source/assumption classifications explicit; Route C provisional, G3 not frozen, site/feed data open'),('Equations editable and symbols defined','PARTIAL','Editable Word equation objects and nomenclature provided; full predictive equations remain unvalidated'),('Material, energy, entropy and exergy balances and closure reported','PARTIAL','Ideal reaction-block material/thermochemistry identities checked; physical stream, energy, entropy and exergy closures BLOCKED'),('Detailed equipment sizing, calculation trail and datasheets complete','PARTIAL','28 datasheets and hand calculations included; majority of equipment sizes/ratings BLOCKED'),('Sensors, actuators, control loops, HMI, alarms/interlocks and failure response documented','PARTIAL','88 proposed loop/function rows, alarm/cause-effect/mode/sequence registers; no approved limits, executable logic or runtime'),('Utilities, waste and screening CAPEX/OPEX quantified','PARTIAL','Electricity/water scenarios and partial electricity cost available; complete utility demand, CAPEX, OPEX and waste rates BLOCKED'),('Six or more sensitivity variables and multiple scenarios analysed','PARTIAL / SCREENING ONLY','Prompt 22 has 12 OAT studies + 1,000-point eight-variable LHS proxy; no physical process optimisation'),('MATLAB architecture, GUI, validation and Python migration addressed','PARTIAL','13 MATLAB modules and GUI source static checks; MATLAB runtime NOT RUN; Python migration partial, 23 tests passed'),('No unsupported compliance, vendor endorsement or certified safety claims','PASS','No vendor guarantee, compliance/certification, SIL or construction claim is made')], 'Table 28. Assignment Topic 27 acceptance checklist', 'Units: not applicable; disposition is evidence status.')
add_callout(doc,'Overall acceptance result','The package is a detailed consolidated academic submission record, but it does not meet all technical acceptance minima. Most importantly, a full base-plus-two-alternative comparison is not achieved; physical balances, thermodynamics, equipment ratings, plant utilities, full costs and safety/automation validation remain incomplete. Do not represent the process model as a validated plant design.',AMBER)

# ---- APPENDIX A WORKED CALCS ----
add_page_break(doc)
add_heading(doc,'Appendix A. Worked Calculation Trail',1,bookmark='appA'); add_back_link(doc)
add_para(doc,'Every calculation below includes the governing equation, units, numerical substitution, intermediate/result, source basis, assumption class and an independent check. Values use source-defined molecular weights and the Prompt 17 independent hand-calculation report. These are ideal/reference calculations or transparent screening examples, not plant measurements.')

calculations=[
('HC-001','Methanol molar rate','n_MeOH = m_MeOH / MW_MeOH','n = 50,000 kg/day / 32.0419 kg/kmol = 1,560.456777 kmol/day','1,560.456777 kmol/day','Hand-calculation report; MW from NIST WebBook property register [SRC-027]','50 t/day component-equivalent assumed target','Independent check: reverse multiply 1,560.456777 kmol/day × 32.0419 kg/kmol = 50,000 kg/day to displayed precision.'),
('HC-002','CO2 theoretical consumption','n_CO2 = 1 × xi_R01; m_CO2 = n_CO2 × MW_CO2','n_CO2 = 1,560.456777 kmol/day; m = 1,560.456777 × 44.0095','68,674.923 kg/day = 68.674923 t/day','R-01 stoichiometry; molecular weight from declared data register','Ideal 1:1 molar CO2:MeOH, 100% carbon selectivity reference','Independent check: C atom balance requires one CO2 carbon per methanol carbon.'),
('HC-003','H2 theoretical consumption','n_H2 = 3 × xi_R01; m_H2 = n_H2 × MW_H2','n_H2 = 3 × 1,560.456777 = 4,681.370331 kmol/day; m = n × 2.01588','9,437.081 kg/day = 9.437081 t/day','R-01 reaction vector and molecular weight data register','No purge, side reactions or unreacted recycle included','Independent check: reaction vector requires three H2 moles per CO2 mole.'),
('HC-004','R-01 reaction water formation','n_H2O,formed = 1 × xi_R01; m = n × MW_H2O','n = 1,560.456777 kmol/day; m = n × 18.01528','28,112.066 kg/day','R-01 stoichiometry and declared MW anchor','No phase split or water recovery assumed','Independent check: H and O atom counts balance in R-01 reaction vector.'),
('HC-005','Electrolyser water and oxygen','xi_E01 = n_H2/2; n_H2O = 2xi_E01; n_O2 = xi_E01','xi_E01 = 4,681.370331/2 = 2,340.685165 kmol/day; n_H2O = 4,681.370331 kmol/day','H2O = 84,336.197 kg/day; O2 = 74,899.116 kg/day','E-01: 2H2O -> 2H2 + O2; declared molecular weights','100% Faradaic stoichiometry and pure component reference; no package losses','Independent check: E-01 atom balance: 4 H atoms and 2 O atoms on both sides per reaction.'),
('HC-006','Net chemical water consumption','n_H2O,net = 3n_MeOH - n_H2O,formed = 2n_MeOH','n = 3(1,560.456777) - 1,560.456777 = 3,120.913554 kmol/day','56,224.131 kg/day','Integrated reaction identity CO2 + 2H2O -> CH3OH + 1.5O2','Excludes treatment reject, cooling, cleaning and water reuse','Independent check: net overall stoichiometric reaction has 2 mol H2O per mol MeOH.'),
('HC-007','C/H/O atom closure','r_atoms = A * N * xi','Using R-01/R-02/E-01 stoichiometric vectors gives residual C=0, H=0, O=0 at stored stoichiometry','0 kmol atoms residual per kmol reaction','Frozen reaction network / fixture','Stoichiometric reaction checks only, not stream-balance closure','Independent check: atom counts can be recomputed from integer reaction coefficients.'),
('HC-008','Integrated mass closure residual','epsilon_m = m_in - m_out','m_in = 68,674.923 + 56,224.131 = 124,899.054 kg/day; m_out = 50,000 + 74,899.116 = 124,899.116 kg/day','epsilon_m = -0.062418 kg/day; residual normalized = 4.9975e-5 %','Independent hand report and frozen benchmark fixture','Residual is due to independently rounded molecular weights; not a balancing stream','Independent check: retain residual; do not force to zero or create artificial waste stream.'),
('HC-009','R-01 standard reaction enthalpy rate','Hdot_R01 = xi_R01 × DeltaH_R01','1,560.456777 kmol/day × 1,000 mol/kmol × (-131.820 kJ/mol) × 1e-6 GJ/kJ','-205.699 GJ/day','NIST formation enthalpies for CO2(g), MeOH(l), H2O(l) [SRC-027–SRC-029]','Standard-state reference at 298.15 K, 0.1 MPa; not reactor heat-removal duty','Independent check: net formation-enthalpy identity reproduces -131.82 kJ/mol within reported rounding.'),
('HC-010','E-01 thermoneutral enthalpy rate','Hdot_E01 = xi_E01 × DeltaH_E01','2,340.685165 kmol/day × 1,000 mol/kmol × 571.660 kJ/mol × 1e-6','1,338.076 GJ/day','NIST standard formation enthalpy references [SRC-027–SRC-029]','Thermoneutral reaction enthalpy only; not electrolyser electrical load','Independent check: E-01 reaction enthalpy 571.66 kJ per 2 mol H2O reaction.'),
('HC-011','Net reaction enthalpy identity','DeltaH_net = DeltaH_R01 + 1.5 DeltaH_E01','-131.820 + 1.5(571.660) = 725.670 kJ/mol MeOH','+725.670 kJ/mol methanol','Combined net stoichiometry and NIST formation enthalpies [SRC-027–SRC-029]','Standard-state net identity, not plant energy closure','Independent check: direct formation enthalpy of CO2 + 2H2O -> CH3OH + 1.5O2 gives same value.'),
('HC-012','CO2 sensible-heat example','Cp = A + Bt + Ct^2 + Dt^3 + E/t^2; Qdot = ndot × Delta h','t=T/1000; Delta h(298.15->523.15 K)=9.349192 kJ/mol; ndot=18.060842 mol/s','Qdot = 168.854 kW','NIST/JANAF Shomate CO2 correlation [SRC-030]','Pure ideal-gas CO2; 298.15 to 523.15 K; not 7 MPa feed heater duty','Independent check: separate Shomate formula implementation agrees to 2.56e-13 kW.'),
('HC-013','Pure methanol latent-heat example','DeltaHvap = A exp(-alpha Tr)(1-Tr)^beta; Qdot = ndot × DeltaHvap','DeltaHvap(298.15 K)=37.48899 kJ/mol; ndot_MeOH=18.060842 mol/s','Qdot = 677.083 kW','NIST WebBook methanol vaporisation correlation [SRC-027]','Pure methanol reference at 298.15 K; not MeOH-water column duty','Independent check: matches frozen hand reference within calculation precision.'),
('HC-014','Illustrative exchanger area','A = Qdot / (U × F × DeltaT_LM)','A = 168,854.29 W / (100 W/m2/K × 1.0 × 30 K)','56.2848 m2','Heat-transfer equation; Q from HC-012','U=100 and LMTD=30 K and F=1 are assumptions; not vendor rating','Independent check: varying U=75–150 and LMTD=20–40 gives 28.14–112.57 m2.'),
('HC-015','W-201 DI-water pump example','Qv = mdot/rho; Pshaft = rho g Qv H / eta_p','mdot=3,514.008 kg/h; rho=997 kg/m3; Qv≈3.5246 m3/h; H=50 m; eta=0.70','Pshaft=0.6837 kW; with 10% flow margin: 3.877 m3/h and 0.752 kW','Pump power equation, DI water density reference','Assumed head/efficiency; line losses, NPSH, treatment reject and vendor curve excluded','Independent check: separate substitution reproduces 0.683743 kW.'),
('HC-016','Electrolyser electricity intensity proxy','e_MeOH = (m_H2/m_MeOH) × SEC_H2','(9,437.081/50,000) kg/kg × 55 kWh/kg H2','10.381 kWh/kg MeOH; 21.627 MW at 50 t/day','DOE alkaline electrolyser SEC reference; Prompt 22 screen [SRC-016]','55 kWh/kg H2 is assumed system scenario, not OEM guarantee; excludes downstream loads','Independent check: e_MeOH × 50,000 kg/day / 24 h = 21.627 MW.'),
('HC-017','Electricity-only operating cost and emissions','C_elec = e_MeOH × tariff; G_elec = e_MeOH × CI','10.381 kWh/kg × ₹5/kWh; 10.381 × 0.40 kg CO2e/kWh','₹51.90/kg MeOH; 4.152 kg CO2e/kg MeOH','Prompt 22 screening assumptions and equations','Assumed tariff/CI; excludes all other plant loads and lifecycle stages','Independent check: direct multiplication; annual cost only applies at 300 days/year.'),
('HC-018','Physical recycle/purge and plant exergy status','Recycle solver requires flash, full stream compositions/inerts, purge criterion and compressor map','S-209 recycle flow, S-207 purge flow and V-301 flash split remain null in fixture','BLOCKED_NOT_COMPUTED; no numeric value','Stream register, numerical-method report and Prompt 21/23 blockers','Missing inputs intentionally not set to zero','Independent check: status/nullness check passes; no physical convergence or exergy closure claimed.')]
for cid,title,eq,sub,res,src,ass,chk in calculations:
    add_sub(doc,f'{cid}. {title}')
    add_math_equation(doc,eq)
    add_para(doc,f'**Substitution and intermediate values:** {sub}',size=9.8)
    add_para(doc,f'**Result:** {res}',size=9.8)
    add_para(doc,f'**Source:** {src}',size=9.3)
    add_para(doc,f'**Assumption / status:** {ass}',size=9.3)
    add_para(doc,f'**Independent check:** {chk}',size=9.3)

# ---- APPENDIX B DATASHEETS ----
add_page_break(doc)
add_heading(doc,'Appendix B. Equipment Datasheets',1,bookmark='appB'); add_back_link(doc)
add_para(doc,'The source package contains 28 editable equipment datasheets. They are reproduced below without promoting a draft or blocked item into a rated equipment selection. Every TBD field remains a design hold point. Equipment datasheet records retain the source revision 0.1-DRAFT.')

def md_to_doc(md_path):
    lines=Path(md_path).read_text(errors='replace').splitlines(); i=0
    while i < len(lines):
        line=lines[i].rstrip()
        if not line.strip(): i+=1; continue
        if line.startswith('# '):
            add_heading(doc,line[2:].strip(),2); i+=1; continue
        if line.startswith('## '):
            add_heading(doc,line[3:].strip(),3); i+=1; continue
        if line.startswith('### '):
            add_heading(doc,line[4:].strip(),3); i+=1; continue
        if line.startswith('|'):
            tbl=[]
            while i<len(lines) and lines[i].strip().startswith('|'):
                tbl.append(lines[i].strip()); i+=1
            parsed=[]
            for ln in tbl:
                cells=[x.strip() for x in ln.strip('|').split('|')]
                if all(re.fullmatch(r':?-{2,}:?',x.replace(' ','')) for x in cells): continue
                parsed.append(cells)
            if len(parsed)>=2:
                headers=parsed[0]; rows=parsed[1:]
                # avoid row column length mismatch
                n=len(headers); rows=[(r+['']*n)[:n] for r in rows]
                t=doc.add_table(rows=1,cols=n); t.style='Table Grid'; t.alignment=WD_TABLE_ALIGNMENT.CENTER; t.autofit=True
                set_repeat_table_header(t.rows[0]);
                for j,h in enumerate(headers):
                    c=t.rows[0].cells[j]; c.text=''; set_cell_shading(c,NAVY); set_cell_margins(c,top=45,bottom=45)
                    pp=c.paragraphs[0]; pp.paragraph_format.space_after=Pt(0); rr=pp.add_run(h); set_run_font(rr,size=7.2,color=WHITE,bold=True)
                for ri,row in enumerate(rows):
                    cells=t.add_row().cells; prevent_row_split(t.rows[-1])
                    for j,x in enumerate(row):
                        c=cells[j]; c.text=''; set_cell_margins(c,top=40,bottom=40)
                        if ri%2: set_cell_shading(c,'F7F9FB')
                        pp=c.paragraphs[0]; pp.paragraph_format.space_after=Pt(0); pp.paragraph_format.line_spacing=0.95
                        add_rich_text(pp,x,size=7.0,color=DARK)
                cap=doc.add_paragraph(); cap.paragraph_format.space_after=Pt(3)
                add_rich_text(cap,'Source datasheet table; units and statuses are as shown in the original table.',size=7.5,color='666666')
            continue
        if line.startswith('- ') or line.startswith('* '):
            add_bullet(doc,line[2:],size=8.9); i+=1; continue
        if re.match(r'^\d+\.\s',line):
            add_number(doc,re.sub(r'^\d+\.\s*','',line),size=8.9); i+=1; continue
        if line.startswith('>'):
            add_callout(doc,'Datasource note',line.lstrip('> ').strip(),PALE); i+=1; continue
        if line.startswith('---'):
            i+=1; continue
        # join wrapped markdown paragraph until blank/new block
        paras=[line]; i+=1
        while i<len(lines) and lines[i].strip() and not lines[i].startswith(('#','|','- ','* ','>','---')) and not re.match(r'^\d+\.\s',lines[i]):
            paras.append(lines[i].strip()); i+=1
        p=doc.add_paragraph(); p.paragraph_format.space_after=Pt(3); p.paragraph_format.line_spacing=1.0; add_rich_text(p,' '.join(paras),size=8.8,color=DARK)

for n,md in enumerate(sorted(DSDIR.glob('*_Datasheet.md')),1):
    add_page_break(doc)
    tag=re.sub(r'_Datasheet.md$','',md.name).replace('_','-')
    add_heading(doc,f'B.{n:02d} {tag} - Equipment Datasheet',2)
    md_to_doc(md)

# ---- APPENDIX C SENSITIVITY PLOTS ----
add_page_break(doc)
add_heading(doc,'Appendix C. Sensitivity and Optimisation Figures',1,bookmark='appC'); add_back_link(doc)
add_para(doc,'The OAT/LHS plots below are the actual Prompt 22 figure files. They use the closed-form equations and assumptions described in Topic 18 and the Prompt 22 handoff. They are not results of MATLAB execution or physical plant optimisation.')
plot_caps=[
('S01_Throughput.png','S01 throughput sensitivity'),('S02_Alkaline_SEC.png','S02 alkaline electrolyser system SEC sensitivity'),('S03_Electricity_Tariff.png','S03 electricity tariff sensitivity'),('S04_Electricity_Carbon_Intensity.png','S04 electricity carbon intensity sensitivity'),('S05_Annual_Availability.png','S05 annual availability sensitivity'),('S06_H2_CO2_Ratio.png','S06 fresh H2/CO2 ratio sensitivity'),('S07_CO2_Purity.png','S07 conditioned CO2 dry purity sensitivity'),('S08_Total_Water.png','S08 total water intensity sensitivity'),('S09_S10_Heat_Exchanger.png','S09/S10 illustrative exchanger U and LMTD sensitivity'),('S11_Pump_Margin.png','S11 W-201 pump flow margin sensitivity'),('S12_Heat_Recovery.png','S12 heat recovery fraction on pure-CO2 duty example'),('M01_LHS_Pareto.png','M01 1,000-point LHS sampled Pareto proxy'),('M02_Rank_Correlation.png','M02 LHS input-output Spearman rank association screen')]
for fn,cap in plot_caps:
    add_figure(doc,PLOT/fn,cap,'Units: axis-specific; all scenarios are SCREENING ONLY.',width=6.4,pagebreak=True)

# ---- APPENDIX D AUTOMATION SAFETY ----
add_page_break(doc)
add_heading(doc,'Appendix D. Automation and Safety Evidence',1,bookmark='appD'); add_back_link(doc)
add_para(doc,'The editable loop, alarm, cause/effect, disturbance, operating-mode, HAZID/What-If and materials-compatibility registers are supplied in the Registers folder. This appendix summarizes their scope and status; the workbook files retain full row-level detail.')
add_table(doc,['Register / evidence item','Rows / scope','Status and key limitation'],[
('Control loop register','88 proposed loop/function rows','All numeric spans/SP/alarms/delays/fail states are design hold points where data is absent'),('Alarm register','70 proposed alarm rows (register data rows)','Priority and cause/action proposal only; limits/deadbands/delays TBD'),('Cause/effect register','29 safeguard-package requirements; 37 entries in later detailed C&E matrix','Not SRS or executable SIS/DCS logic'),('Safe-state principles','16 conceptual principles','Not an approved response procedure; no SIL assigned'),('HAZID / What-If','50 records; 15 proposed HAZOP nodes','Preliminary screening only; no risk score or action closeout'),('Materials compatibility','28 records; 15 materials hold points','No final metallurgy or corrosion allowance'),('Disturbance response','14 principal disturbance cases','Qualitative sequence review; no dynamic or I/O fault test'),('Operating mode / sequence','13 mode/state labels; S00–S110 start-up skeleton','No commissioned procedure; vendor/HAZOP review required'),('HMI specification','11 display/page groups','Source specification only; UI runtime not run')], 'Table 29. Automation and safety register coverage', 'Counts from source package; all entries conceptual unless explicitly verified.')
add_para(doc,'The principal hazard themes are hydrogen leakage/flammability; oxygen enrichment and incompatible oxygen service; CO toxicity; CO2 asphyxiation; methanol toxicity/flammability; high pressure and blocked-in thermal expansion; reactor hot spots/loss of heat removal; KOH corrosion/burn hazards; catalyst/adsorbent handling; wastewater and incompatible drains; and common-cause loss of power, cooling, instrument air or control communications. Formal HAZOP, LOPA/SIL, QRA, hazardous-area classification, relief/vent sizing, fire protection, emergency response and materials selection are not completed.')

# ---- APPENDIX E OPEN DECISIONS ----
add_page_break(doc)
add_heading(doc,'Appendix E. Open Decisions, Limitations and Recommendations',1,bookmark='appE'); add_back_link(doc)
add_para(doc,'The open-decision register contains 24 unresolved inputs and one fixed academic-scope constraint. The following closure sequence is recommended before the work is advanced to a physical process model:')
for item in [
'Approve the production route and source archetype, with chain-of-custody and carbon-origin documentation for Route C; maintain Route B as blocked until biomass and syngas data are available.',
'Freeze the design basis and battery limits: site, feed assays, product specification, operating/design envelope, throughput, operating hours and utility availability.',
'Obtain catalyst-specific kinetic information valid for the selected pressure and composition. Resolve the 70 bar(a) draft basis versus approximately 50–51 bar kinetic evidence mismatch.',
'Complete the high-pressure PR78/SRK binary parameter set, phase stability, high-pressure flash validation and methanol-water VLE regression with independent data.',
'Solve physical stream balances, recycle/purge, separation, column MESH and all 55 stream state fields; verify residual tolerances and element closure.',
'Obtain electrolyser/compressor/pump/exchanger vendor data and complete utility source/return conditions; perform rating and upset/turndown checks.',
'Complete plant energy, entropy and exergy balances; define a site dead state and quantify irreversibility only after validated stream properties are available.',
'Complete environmental MRV boundary, water source/withdrawal, emission factors, waste assays and site-specific legal register; do not infer regulatory certification.',
'Obtain dated vendor budget quotations and a defined estimate class/currency/year/site before CAPEX/OPEX/LCOM.',
'Run MATLAB source tests and GUI in a recorded supported release; obtain MATLAB output artefacts and compare them to the same frozen Python/hand fixture. Do not claim parity until this is done.',
'Complete formal HAZOP/LOPA/SIL/QRA and package safety reviews when P&IDs, process intent, relief cases and vendor data are mature.'
]: add_number(doc,item,size=9.4)
add_table(doc,['Limitation','Consequence for interpretation'],[
('Route/G3 design basis provisional','No frozen physical design or final route recommendation'),('Kinetic data pressure mismatch','No validated reactor conversion, catalyst mass or reactor sizing'),('High-pressure mixture EOS / VLE absent','No high-pressure stream enthalpy/phase split/distillation result'),('Stream states and physical recycle/purge absent','No plant-wide flow rates or mass/energy closure'),('Plant entropy/exergy incomplete','No entropy generation, exergy efficiency or ED ranking'),('Vendor data absent','No actual machine nameplate/rating/guarantee'),('Site utilities/costs absent','No full utility consumption, CAPEX/OPEX or LCOM'),('Formal risk studies absent','No SIL, approved trip limits, relief design or statutory approval'),('MATLAB runtime/GUI absent','No MATLAB/GUI execution claim or MATLAB/Python parity')], 'Table 30. Material limitations and downstream consequence', 'Units: not applicable.')

# ---- APPENDIX F REFERENCES ----
add_page_break(doc)
add_heading(doc,'Appendix F. References and Source Provenance',1,bookmark='appF'); add_back_link(doc)
add_para(doc,'Citations in the report use the exact source IDs in `ENERGY008_Source_Register.xlsx`. The source register contains 74 records with author/organisation, year, exact title, publication/standard version, DOI/URL, retrieval date, data type, conditions/ranges, uncertainty/caveat, applicability, intended use, quality score and access status. The full register and the original BibTeX bibliography are included in the handoff.')
add_para(doc,'Peer-reviewed experimental kinetics, peer-reviewed process/catalyst reviews, official Indian legal instruments, official standards catalogues, NIST/JANAF/IAPWS reference data, vendor/industry context and assumptions are distinguished in the source register. Paywalled/licensed standards and databases are not reproduced as text. A source quality score is a project triage aid, not a peer-review certification.',size=8.4,color='555555')
# build exact reference list from artifact_tool source workbook
swb=SpreadsheetFile.import_xlsx(Blob.load(str(REG/'ENERGY008_Source_Register.xlsx')))
sheet=swb.worksheets.get_item('Source Register')
refvals=sheet.get_range('A4:P78').values
headers=refvals[0]
source_rows=refvals[1:]
REFERENCE_LIST=[]
for row in source_rows:
    if not row or not row[0]: continue
    d=dict(zip(headers,row)); REFERENCE_LIST.append(d)
for d in REFERENCE_LIST:
    p=doc.add_paragraph(); p.paragraph_format.left_indent=Inches(.22); p.paragraph_format.first_line_indent=Inches(-.22); p.paragraph_format.space_after=Pt(2); p.paragraph_format.line_spacing=1.0
    txt=f"[{d.get('Source_ID')}] {d.get('Author_or_Organisation')} ({d.get('Year_or_Date')}). {d.get('Exact_Title')}. {d.get('Journal_Standard_or_Version') or ''}."
    if d.get('DOI'): txt+=f" DOI: {d.get('DOI')}."
    if d.get('URL'): txt+=f" URL: {d.get('URL')}."
    txt+=f" Retrieved {d.get('Retrieval_Date')}. Data type: {d.get('Data_Type')}. Quality {d.get('Quality_Score_1_to_5')}/5. Access: {d.get('Access_Status')}."
    add_rich_text(p,txt,size=7.7,color=DARK)

# Document metadata
props=doc.core_properties
props.title='ENERGY-008 Green Methanol Synthesis - Technical Report'
props.subject='Utility integration and energy KPIs; evidence-controlled academic engineering report'
props.author='ENERGY-008 project submission'
props.keywords='ENERGY-008, green methanol, process design, utility integration, verification'
props.comments='Final academic consolidation; underlying engineering basis remains Rev 0.1-DRAFT and not approved for plant use.'

# Write draft
OUT.parent.mkdir(parents=True,exist_ok=True)
doc.save(OUT)

# Save figures/tables initial register to Report; pages inserted after final pagination script
with open(ROOT/'Report'/'Figure_Register.csv','w',newline='',encoding='utf-8') as f:
 w=csv.DictWriter(f,fieldnames=['Figure_No','Caption','Units_Status','Source_File']); w.writeheader()
 for x in FIG_REG: w.writerow({'Figure_No':x['number'],'Caption':x['caption'],'Units_Status':x['units'],'Source_File':Path(x['path']).name})
with open(ROOT/'Report'/'Table_Register.csv','w',newline='',encoding='utf-8') as f:
 w=csv.DictWriter(f,fieldnames=['Table_No','Caption','Units_Status']); w.writeheader()
 for i,x in enumerate(TABLE_REG,1): w.writerow({'Table_No':i,'Caption':x['caption'],'Units_Status':x['units']})
# Export human-readable source reference list CSV exactly from source register fields
with open(ROOT/'Bibliography'/'ENERGY008_Reference_List.csv','w',newline='',encoding='utf-8') as f:
 w=csv.writer(f); w.writerow(headers); w.writerows(source_rows)
print('DOCX_WRITTEN',OUT,'figures',len(FIG_REG),'tables',len(TABLE_REG),'refs',len(REFERENCE_LIST))
