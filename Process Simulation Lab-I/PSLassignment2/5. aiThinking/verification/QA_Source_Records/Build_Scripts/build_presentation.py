from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.enum.shapes import MSO_SHAPE
from pptx.enum.dml import MSO_THEME_COLOR
from pathlib import Path

ROOT=Path('/mnt/data/ENERGY008_Final')
ASSET=Path('/mnt/data/energy008_sources/phase_assets')
PLOTS=Path('/mnt/data/energy008_sources/ENERGY008_Prompt22_Sensitivity_Optimisation/22_Sensitivity_Optimisation/Plots')
OUT=ROOT/'Presentation'/'ENERGY008_Short_Presentation.pptx'
OUT.parent.mkdir(parents=True,exist_ok=True)

prs=Presentation(); prs.slide_width=Inches(13.333); prs.slide_height=Inches(7.5)
blank=prs.slide_layouts[6]
NAVY=RGBColor(23,54,93); BLUE=RGBColor(31,78,121); MID=RGBColor(91,155,213); LIGHT=RGBColor(221,235,247); PALE=RGBColor(242,246,250); GREY=RGBColor(100,110,120); DARK=RGBColor(35,42,48); AMBER=RGBColor(199,127,36); RED=RGBColor(165,55,55); WHITE=RGBColor(255,255,255); GREEN=RGBColor(67,122,97)
FONT='Aptos'; SERIF='Georgia'

def textbox(slide,x,y,w,h,text,size=16,color=DARK,bold=False,font=FONT,align=PP_ALIGN.LEFT,margin=0.06,italic=False):
    sh=slide.shapes.add_textbox(Inches(x), Inches(y), Inches(w), Inches(h)); tf=sh.text_frame; tf.clear(); tf.word_wrap=True
    tf.margin_left=tf.margin_right=Inches(margin); tf.margin_top=tf.margin_bottom=Inches(margin)
    p=tf.paragraphs[0]; p.alignment=align
    r=p.add_run(); r.text=str(text); r.font.name=font; r.font.size=Pt(size); r.font.bold=bold; r.font.italic=italic; r.font.color.rgb=color
    return sh

def rect(slide,x,y,w,h,fill, line=None, radius=False):
    shape=slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE if radius else MSO_SHAPE.RECTANGLE, Inches(x), Inches(y), Inches(w), Inches(h))
    # Remove inherited theme effects (notably shadows) so edge-aligned shapes do not bleed into the canvas padding.
    style = shape._element.find('{http://schemas.openxmlformats.org/presentationml/2006/main}style')
    if style is not None: shape._element.remove(style)
    shape.fill.solid(); shape.fill.fore_color.rgb=fill
    shape.line.color.rgb=line or fill
    return shape

def title(slide,txt,sub=None,section=None):
    rect(slide,0,0,13.333,0.18,NAVY)
    textbox(slide,.58,.38,12.15,.48,txt,26,NAVY,True,SERIF)
    if sub: textbox(slide,.61,.92,12.0,.35,sub,11,GREY,False)
    if section: textbox(slide,11.35,.42,1.35,.25,section.upper(),8,MID,True,align=PP_ALIGN.RIGHT)

def footer(slide,idx,source='ENERGY-008 | Rev 1.0 | 02 Nov 2026'):
    rect(slide,.55,7.12,12.25,.012,LIGHT)
    textbox(slide,.6,7.17,10.7,.18,source,7.5,GREY)
    textbox(slide,12.0,7.15,.65,.22,f'{idx:02d}',8,GREY,True,align=PP_ALIGN.RIGHT)

def bulletbox(slide,x,y,w,h,items,size=14,color=DARK,bullet_color=BLUE,spacing=9):
    sh=slide.shapes.add_textbox(Inches(x), Inches(y), Inches(w), Inches(h)); tf=sh.text_frame; tf.clear(); tf.word_wrap=True
    tf.margin_left=Inches(.03); tf.margin_right=Inches(.04); tf.margin_top=Inches(.02); tf.margin_bottom=Inches(.02)
    for i,item in enumerate(items):
        p=tf.paragraphs[0] if i==0 else tf.add_paragraph(); p.text=''; p.level=0; p.space_after=Pt(spacing)
        r=p.add_run(); r.text='• '; r.font.name=FONT; r.font.size=Pt(size); r.font.bold=True; r.font.color.rgb=bullet_color
        r=p.add_run(); r.text=item; r.font.name=FONT; r.font.size=Pt(size); r.font.color.rgb=color
    return sh

def metric(slide,x,y,w,h,value,label,sub='',color=BLUE):
    rect(slide,x,y,w,h,PALE,LIGHT,True)
    textbox(slide,x+.15,y+.13,w-.3,.48,value,25,color,True,SERIF)
    textbox(slide,x+.15,y+.68,w-.3,.34,label,11,NAVY,True)
    if sub: textbox(slide,x+.15,y+1.02,w-.3,h-1.08,sub,9,GREY)

def add_img(slide,path,x,y,w,h=None):
    path=Path(path)
    if not path.exists():
        textbox(slide,x,y,w,.4,f'[Missing source image: {path.name}]',10,RED)
        return
    if h is None: slide.shapes.add_picture(str(path), Inches(x), Inches(y), width=Inches(w))
    else:
        from PIL import Image
        im=Image.open(path); ratio=im.width/im.height; box=w/h
        if ratio>box:
            ww=w; hh=w/ratio; xx=x; yy=y+(h-hh)/2
        else:
            hh=h; ww=h*ratio; yy=y; xx=x+(w-ww)/2
        slide.shapes.add_picture(str(path), Inches(xx), Inches(yy), width=Inches(ww), height=Inches(hh))

def make_slide(txt,sub=None,section=None):
    s=prs.slides.add_slide(blank); title(s,txt,sub,section); return s

# 1 cover
s=prs.slides.add_slide(blank); s.background.fill.solid(); s.background.fill.fore_color.rgb=WHITE; rect(s,0,0,13.333,2.35,NAVY)
textbox(s,.75,.55,11.8,.3,'ENERGY ASSIGNMENT 008  |  ENERGY & RENEWABLE INDUSTRIAL SYSTEMS',10,RGBColor(191,213,232),True)
textbox(s,.75,1.0,12, .8,'GREEN METHANOL SYNTHESIS',31,WHITE,True,SERIF)
textbox(s,.78,1.82,11.3,.36,'Utility integration and energy KPIs',17,RGBColor(220,232,244))
textbox(s,.82,2.85,11.8,.55,'FINAL ENGINEERING SYNTHESIS',18,NAVY,True,SERIF)
textbox(s,.82,3.53,11.7,.55,'Route C working reference: biogenic CO₂ + renewable electrolytic H₂; alkaline electrolysis reference with PEM flexibility comparator.',16,DARK)
rect(s,.82,4.5,11.7,1.05,PALE,LIGHT,True)
textbox(s,1.05,4.72,11.2,.6,'Evidence-controlled academic design review  •  Rev 1.0  •  02 November 2026\nDesign basis Rev 0.1-DRAFT; G3 design freeze not approved. Not a certified plant design.',12,BLUE,True)
textbox(s,.82,6.25,11.7,.35,'Student: Mridun Gupta  |  Roll: J24IMT624  |  Institute of Chemical Technology, Mumbai Marathwada Campus, Jalna',10,GREY)
footer(s,1)

# 2 executive decision
s=make_slide('Executive decision','What the current evidence supports, and what it does not.','Decision')
metric(s,.65,1.55,2.85,1.55,'50 t/day','Reference component basis','Ideal stoichiometric calculation, not actual production.',BLUE)
metric(s,3.72,1.55,2.85,1.55,'68.675 t/day','Minimum CO₂','1 mol CO₂ per mol MeOH in ideal reaction.',BLUE)
metric(s,6.79,1.55,2.85,1.55,'9.437 t/day','Minimum H₂','3 mol H₂ per mol MeOH; recycle/purge absent.',BLUE)
metric(s,9.86,1.55,2.85,1.55,'121 pages','Technical report','28 equipment datasheets; 33 figures; 30 numbered tables.',BLUE)
bulletbox(s,.78,3.55,11.9,2.75,[
    'Retain Route C as the working academic reference, but do not freeze the route or design basis until site/feed/product inputs and G3 decisions are approved.',
    'The physical plant balances, reactor performance, VLE, recycle/purge, utilities, equipment ratings and full CAPEX/OPEX remain blocked or screening-only.',
    'Prompt 22 adds structured OAT and LHS screening; it does not validate the physical process or establish a global operating optimum.'
],15)
footer(s,2,'Sources: ENERGY008 hand-calculation report; Prompts 21–23 handoffs; assignment PSLassignment2.pdf.')

# 3 evidence classification
s=make_slide('Evidence classification','The distinction between calculated reference values, screening assumptions and unresolved plant data.','Basis')
rows=[('Calculated reference','Ideal stoichiometric component ledger; atom closure; thermochemical reference identities.','Reproducible, but not a plant-wide balance.'),('Screening only','Compressor, exchanger, pump, electricity, tariff, water, throughput, OAT/LHS scenario calculations.','Illustrative assumptions and limited boundary.'),('Blocked / not run','High-pressure EOS/VLE, catalyst kinetics at draft pressure, recycle/purge, plant entropy/exergy, relief sizing, plant economics.','No numerical value asserted.'),('Runtime evidence','Python migration: 23 pytest passes; MATLAB/GUI runtime and MATLAB/Python parity not run.','Software test evidence is not plant validation.')]
# custom 3-col table
x0=.72;y0=1.55; widths=[2.1,5.0,5.0]; rh=.95
for j,h in enumerate(['Evidence tier','Examples','Interpretation']):
    xx=x0+sum(widths[:j]); rect(s,xx,y0,widths[j],.45,NAVY); textbox(s,xx+.1,y0+.08,widths[j]-.2,.24,h,12,WHITE,True)
for i,row in enumerate(rows):
    yy=y0+.45+i*rh
    for j,val in enumerate(row):
        xx=x0+sum(widths[:j]); rect(s,xx,yy,widths[j],rh,PALE if i%2==0 else WHITE,LIGHT)
        textbox(s,xx+.12,yy+.1,widths[j]-.24,rh-.18,val,11,NAVY if j==0 else DARK,j==0)
textbox(s,.82,6.12,11.8,.52,'No CPS-01 or CPS-22 process values, equations, thermodynamic models or conclusions have been imported into ENERGY-008.',12,RED,True)
footer(s,3,'Sources: ENERGY008_Hand_Calculation_Report.md; ENERGY008_Unit_Integration_Test_Report.md; Prompt 22/23 handoffs.')

# 4 route comparison
s=make_slide('Route architecture and alternatives','A selected working route is not the same as an approved design-basis freeze.','Routes')
# three panels
panels=[('ROUTE C  |  WORKING REFERENCE','Biogenic CO₂ + renewable electrolytic H₂','ALK reference; PEM flexibility comparison. CO₂ hydrogenation core.','Selected for continued academic modelling; source assay, chain of custody and G3 approval remain open.',BLUE),('ROUTE A  |  ALTERNATIVE','Existing industrial CO₂ + renewable H₂','Same synthesis core; different carbon-source and capture/conditioning front end.','Common-core comparison only. Facility, carbon origin, capture energy and source quality are not selected.',GREEN),('ROUTE B  |  BLOCKED','Sustainable biomass → gasification → syngas','Requires gasifier, raw-gas cleanup, syngas conditioning and certification interpretation.','No comparable integrated balance or validated cost. Retain as unresolved alternative, not a quantified winner.',AMBER)]
for i,(tag,name,desc,status,col) in enumerate(panels):
    x=.68+i*4.2; rect(s,x,1.55,3.85,4.9,PALE,LIGHT,True); rect(s,x,1.55,3.85,.48,col)
    textbox(s,x+.16,1.66,3.54,.23,tag,10,WHITE,True)
    textbox(s,x+.18,2.22,3.45,.6,name,17,NAVY,True,SERIF)
    textbox(s,x+.18,3.05,3.45,1.08,desc,12,DARK)
    textbox(s,x+.18,4.38,3.45,1.55,status,11,GREY)
footer(s,4,'Source: ENERGY008_Literature_Review.md; ENERGY008_Route_Decision_Report.md; assignment Topic 2.')

# 5 PFD
s=make_slide('Conceptual process flow diagram','Route C boundary: CO₂ conditioning, electrolysis, synthesis loop, crude separation, purification and product/waste systems.','Process')
add_img(s,ASSET/'ENERGY008_PFD.png',.55,1.35,12.2,5.45)
textbox(s,.7,6.72,12,.25,'Conceptual PFD only: numeric stream states, physical recycle/purge, equipment design ratings and utility returns are not approved.',9,RED,True)
footer(s,5,'Source: ENERGY008_PFD.svg / editable ENERGY008_PFD.drawio; Stream Register Rev 0.1-DRAFT.')

# 6 design basis and limits
s=make_slide('Design basis and validity holds','Current values are reference/screening anchors, not frozen design inputs.','Basis')
metric(s,.75,1.55,2.75,1.45,'25 / 50 / 55','t/day throughput ladder','Minimum stable / normal / max continuous, scenario only.')
metric(s,3.7,1.55,2.75,1.45,'60.5 t/day','Design capacity screen','55 t/day × 1.10 flow allowance.')
metric(s,6.65,1.55,2.75,1.45,'7 MPa(a)','Draft synthesis pressure','70 bar(a); kinetic pressure mismatch.')
metric(s,9.6,1.55,2.75,1.45,'250 °C','Draft synthesis temperature','Broad literature context 200–300 °C.')
bulletbox(s,.85,3.45,11.6,2.5,[
    'Graaf et al. and Vanden Bussche/Froment kinetic data are identified to about 50–51 bar; the 70 bar(a) draft point is outside the cited model range.',
    'No validated high-pressure CO₂/H₂/CO/CH₃OH/H₂O EOS binary parameters, mixture phase-stability result or methanol–water VLE model was run.',
    'Feed source assays, product/customer specification, site utility conditions/tariffs, vendor maps and site water boundary remain unresolved.'
],14,bullet_color=AMBER)
footer(s,6,'Sources: ENERGY008_Literature_Review.md; ENERGY008_Model_Assumptions_and_Validity.md; ENERGY008_Design_Basis.xlsx.')

# 7 material ledger
s=make_slide('Ideal stoichiometric material reference','50,000 kg/day methanol component-equivalent; synthesis and electrolyser stoichiometry only.','Balances')
metrics=[('CO₂ minimum','68,674.923 kg/day'),('H₂ minimum','9,437.081 kg/day'),('Electrolyser DI water','84,336.197 kg/day'),('O₂ theoretical','74,899.116 kg/day'),('Reaction water','28,112.066 kg/day'),('Net chemical water','56,224.131 kg/day')]
for i,(lab,val) in enumerate(metrics):
 x=.7+(i%3)*4.18; y=1.55+(i//3)*1.62
 metric(s,x,y,3.8,1.35,val,lab,'Ideal component-equivalent calculation; losses, purge, recycle, treatment reject and phase split excluded.',BLUE)
textbox(s,.82,5.12,11.8,.8,'Overall net reaction:  CO₂ + 2 H₂O → CH₃OH + 1.5 O₂\nAtom residuals (C/H/O): zero in stored stoichiometry. Mass residual: −0.062418 kg/day from independently rounded molecular weights; retained, not forced to zero.',12,DARK,True)
textbox(s,.82,6.15,11.8,.4,'The physical 55-stream plant ledger, actual recycle and purge remain BLOCKED_NOT_COMPUTED.',12,RED,True)
footer(s,7,'Source: ENERGY008_Hand_Calculation_Report.md; ENERGY008_Benchmark_Fixture.json.')

# 8 energy & utilities
s=make_slide('Energy and utility screening','The electricity figures represent the electrolyser system scenario only.','Energy')
metric(s,.72,1.55,2.75,1.45,'55 kWh/kg H₂','ALK system SEC screen','Not vendor-guaranteed; system boundary per input scenario.')
metric(s,3.67,1.55,2.75,1.45,'10.381 kWh/kg','MeOH electricity','Derived electrolyser-only electricity intensity.')
metric(s,6.62,1.55,2.75,1.45,'21.627 MW','Electrolyser load','At 50 t/day MeOH reference basis.')
metric(s,9.57,1.55,2.75,1.45,'84.336 t/day','DI water stoichiometry','Feedstock water only; not total site withdrawal.')
bulletbox(s,.82,3.55,11.6,2.25,[
    'CO₂ sensible-heating example: 168.854 kW for pure ideal gas from 298.15 to 523.15 K, not a 7 MPa feed heater duty.',
    'Methanol latent heat example: 677.083 kW pure-component reference, not a distillation reboiler/condenser duty.',
    'Utility interface register contains 10 services, but site flowrates, return conditions, utility network and cooling/steam integration are not quantified.'
],13)
footer(s,8,'Source: ENERGY008_Hand_Calculation_Report.md; ENERGY008_Utility_Summary.xlsx; ENERGY008_Energy_Balance.xlsx.')

# 9 heat integration and exergy
s=make_slide('Heat integration and exergy status','The current drawings define candidates, not calculated heat targets or exergy performance.','Thermodynamics')
add_img(s,ASSET/'ENERGY008_Heat_Network.png',.65,1.45,6.0,4.35)
add_img(s,ASSET/'ENERGY008_Composite_Curves.png',6.85,1.45,5.8,4.35)
textbox(s,.85,5.97,11.7,.65,'HX-301 is the only process-process heat-recovery candidate (S-203 → S-201). Stream temperatures/enthalpies are unavailable, so pinch temperatures, utility targets, heat-recovery duty and area remain uncalculated.',12,RED,True)
footer(s,9,'Sources: ENERGY008_Heat_Integration_Report.md; ENERGY008_Heat_Network.drawio; ENERGY008_Exergy_Balance.xlsx.')

# 10 equipment
s=make_slide('Equipment sizing and datasheets','28 tagged equipment datasheets are present; most remain blocked by missing physical design inputs.','Equipment')
metric(s,.75,1.55,3.65,1.55,'28','Equipment datasheets','Service and connections, capacity, materials, safeguards and closure fields.')
metric(s,4.83,1.55,3.65,1.55,'271.7 kW','K-201 normal screen','20→70 bar(a), two-stage ideal-gas estimate; eta assumptions.')
metric(s,8.91,1.55,3.65,1.55,'522.2 kW','K-201 design screen','15→100 bar(a), assumed compression basis; not a compressor rating.')
bulletbox(s,.85,3.6,11.5,2.35,[
    'W-201 pump: 3.5246 m³/h and 0.684 kW shaft power at 50 m head / 70% efficiency; 10% flow allowance gives 3.877 m³/h and 0.752 kW.',
    'HX-301 remains a candidate with no thermal rating; R-301 catalyst mass/volume and reactor sizing are blocked by kinetics, property and heat-removal gaps.',
    'Vendor curves, design P/T, relief cases, mechanical code checks, metallurgy review and NPSH/network analysis are not complete.'
],13)
footer(s,10,'Sources: ENERGY008_Equipment_Feasibility_Report.md; ENERGY008_Equipment_Datasheets_v0.1.0; hand calculation HC-014–HC-016.')

# 11 automation
s=make_slide('Automation and operating sequence','An extensive conceptual control register exists, but numerical spans, tuning and safety functions remain design hold points.','Automation')
add_img(s,ASSET/'ENERGY008_Automation_State_Diagram.png',.65,1.4,6.3,4.9)
items=[('88','proposed loop/function rows'),('70','alarm register data rows'),('29','candidate cause/effect rows'),('16','safe-state principles'),('14','disturbance scenarios')]
for i,(num,lab) in enumerate(items):
 y=1.55+i*.92; rect(s,7.25,y,1.12,.62,BLUE if i<2 else NAVY); textbox(s,7.3,y+.1,1.02,.35,num,18,WHITE,True,align=PP_ALIGN.CENTER); textbox(s,8.55,y+.12,3.75,.35,lab,12,DARK,True)
textbox(s,7.25,6.25,5.25,.45,'No SIL claim; formal HAZOP / LOPA / QRA and independent SIS lifecycle work are outstanding.',10,RED,True)
footer(s,11,'Sources: ENERGY008_Control_Philosophy.md; loop/alarm/safeguard registers; start-stop sequence.')

# 12 safety environment
s=make_slide('Safety, environment and compliance boundary','A hazard-screening package is not a certified process-safety study or a green-methanol certificate.','EHS')
bulletbox(s,.75,1.5,6.05,4.8,[
    'HAZID / What-If register: 50 records across 15 proposed nodes; 29 candidate cause/effect rows.',
    'Hazards include H₂, O₂, CO, CO₂, methanol, KOH, high pressure/temperature, catalyst, drains and utilities.',
    'No approved relief-device sizing, vent/flare design, area classification, SIL, fire protection or formal HAZOP / LOPA / QRA.',
    'Waste stream types identified, but rates, compositions and disposal routes are not closed.'
],13)
rect(s,7.15,1.55,5.25,4.65,PALE,LIGHT,True)
textbox(s,7.45,1.83,4.6,.35,'Indian regulatory evidence',15,NAVY,True,SERIF)
textbox(s,7.45,2.35,4.6,1.0,'MNRE Green Methanol Standard (27 Feb 2026): green hydrogen required; non-biogenic stage emissions ceiling 0.44 kg CO₂e/kg methanol on the defined rolling 12-month basis.',12,DARK)
textbox(s,7.45,3.67,4.6,1.2,'No complete lifecycle/emissions ledger or MRV certification procedure was verified for this project. Electricity-related screening emissions are not a certification result.',12,RED,True)
textbox(s,7.45,5.2,4.6,.55,'Product specification remains a hold point; BIS IS 517:2020 and amendments require full-text/contract alignment.',10,GREY)
footer(s,12,'Sources: ENERGY008_Safety_Study_Limitations.md; ENERGY008_Environmental_and_Indian_Compliance_Screen.md; MNRE Green Methanol Standard [SRC-001].')

# 13 sensitivity
s=make_slide('Sensitivity and multivariable screening','Prompt 22 extends sensitivity coverage, but its output is a scenario screen rather than a process optimisation.','Sensitivity')
add_img(s,PLOTS/'M01_LHS_Pareto.png',.55,1.35,6.2,4.8)
add_img(s,PLOTS/'M02_Rank_Correlation.png',6.85,1.35,5.9,4.8)
textbox(s,.75,6.28,11.9,.45,'12 OAT studies + 1,000-point Latin Hypercube (8 variables; seed 20261102). P05/P50/P95 are conditional scenario quantiles, not confidence intervals.',11,RED,True)
footer(s,13,'Source: ENERGY008_Prompt22_Handoff.md; LHS_samples.csv; LHS_output_intervals.csv; plots S01–S12 / M01–M02.')

# 14 economics
s=make_slide('Economics: electricity-only scenario','The full CAPEX/OPEX model is blocked; the following is only a transparent variable electricity contribution.','Economics')
metric(s,.75,1.55,3.65,1.55,'₹51.90/kg','MeOH electricity cost','Assumed ₹5/kWh × 10.381 kWh/kg MeOH.')
metric(s,4.83,1.55,3.65,1.55,'₹778.6 M/y','Annual electricity spend','Assumed 300 d/y and 50 t/day; electrolyser only.')
metric(s,8.91,1.55,3.65,1.55,'4.152 kg','CO₂e/kg MeOH','Assumed grid intensity 0.40 kg/kWh; power scope only.')
bulletbox(s,.9,3.65,11.4,2.2,[
    'Annual reference production = 15,000 t/y; electrolyser electricity = 155.712 GWh/y.',
    'The electricity case excludes CO₂ capture, compression, synthesis compression, refrigeration, distillation, site auxiliaries, maintenance, labor, catalyst, water treatment, waste, financing and by-product credits.',
    'No defensible total CAPEX, total OPEX, product cost, NPV or payback is available. Electricity tariff and carbon-intensity values are assumptions, not a supplier contract or grid measurement.'
],13)
footer(s,14,'Source: ENERGY008_Operating_Window_and_Recommendation.md; design-basis scenario inputs DB; calculation in Topic 17.')

# 15 validation status
s=make_slide('Software verification and validation status','A clean software test is not evidence of a validated physical plant model.','Verification')
add_img(s,Path('/mnt/data/energy008_work/verification_status.png'),.7,1.6,5.4,3.8)
rows=[('Python migration','23 pytest tests passed; six CLI run directories; parity vs frozen hand fixture passed for 18 numeric rows.'),('MATLAB runtime','31 source-defined MATLAB tests: NOT RUN; runtime unavailable in recorded environment.'),('GUI','Static assertions recorded; MATLAB App runtime GUI validation NOT RUN.'),('MATLAB/Python parity','NOT RUN. Physical process model remains incomplete.'),('Prompt 21 curated register','82 records: 40 PASS, 2 FAIL, 14 BLOCKED, 19 NOT RUN, 7 SCREENING ONLY.')]
x=6.45;y=1.55
for i,(a,b) in enumerate(rows):
 yy=y+i*.9; rect(s,x,yy,5.8,.77,PALE if i%2==0 else WHITE,LIGHT,True); textbox(s,x+.15,yy+.08,1.75,.55,a,10,NAVY,True); textbox(s,x+1.95,yy+.07,3.65,.61,b,9,DARK)
footer(s,15,'Sources: ENERGY008_Unit_Integration_Test_Report.md; ENERGY008_Verification_Matrix.xlsx; Prompt 23 migration handoff.')

# 16 recommendations
s=make_slide('Recommendation and Prompt 25 handoff','Advance by resolving the blocking engineering basis, not by presenting screening outputs as a plant design.','Close-out')
steps=[('1','Approve route and carbon source','Confirm Route C, source archetype, carbon origin and chain-of-custody evidence; retain Route A/B comparison status.'),('2','Freeze G3 design basis','Resolve throughput, site, feed assay, product grade, operating envelope, uptime, utility battery limits, water and emissions boundary.'),('3','Close model validity','Obtain validated catalyst kinetic data at selected pressure; freeze EOS kij, phase stability and methanol-water VLE.'),('4','Close physical design','Solve physical stream/recycle/purge balances; size reactor, separator, column, utilities and relief systems with vendor/site data.'),('5','Complete formal assurance','Run MATLAB GUI/tests in supported runtime, MATLAB/Python parity, formal HAZOP/LOPA/SIL as applicable, MRV and economics.')]
for i,(n,h,b) in enumerate(steps):
 y=1.45+i*1.02; rect(s,.7,y,.55,.6,BLUE); textbox(s,.78,y+.13,.38,.25,n,16,WHITE,True,align=PP_ALIGN.CENTER); textbox(s,1.45,y+.02,3.2,.34,h,13,NAVY,True); textbox(s,4.55,y+.01,7.9,.62,b,11,DARK)
rect(s,.75,6.62,11.85,.32,AMBER); textbox(s,.88,6.67,11.5,.2,'Submission status: report + review PDF + short deck prepared; outstanding engineering and runtime gaps carried forward to Prompt 25.',9,WHITE,True)
footer(s,16,'Handoff version: ENERGY008-MODEL-0.1.0 / RXN-0.1.0 / DATA-0.1.0; report ENERGY008-REP-001 Rev 1.0.')

# Core metadata
prs.core_properties.title='ENERGY-008 Green Methanol Synthesis – Short Engineering Presentation'
prs.core_properties.subject='Utility integration and energy KPIs; evidence-controlled academic engineering synthesis'
prs.core_properties.author='ENERGY-008 project submission'
prs.core_properties.keywords='ENERGY-008, green methanol, balances, utilities, automation, validation'
prs.save(OUT)
print('WROTE',OUT,'slides',len(prs.slides))
