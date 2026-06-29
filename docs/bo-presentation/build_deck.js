const pptxgen = require("pptxgenjs");
const React = require("react");
const ReactDOMServer = require("react-dom/server");
const { execFileSync } = require("child_process");
const FA = require("react-icons/fa");

// ─── Palette ────────────────────────────────────────────────────
const NAVY   = "12203F";
const NAVY2  = "1B2E54";
const NAVY3  = "21386A";
const INK    = "1A2333";
const MUTED  = "5A6478";
const LIGHT  = "F4F6FB";
const CARD   = "FFFFFF";
const TEAL   = "2EC4B6";
const AMBER  = "E9A23B";
const RED    = "D64045";
const ICE    = "C8DAEF";
const BORDER = "D8E2F0";
const HFONT  = "Georgia";
const BFONT  = "Calibri";
const W = 13.3, H = 7.5;

// ─── Icon helper (rsvg-convert) ─────────────────────────────────
async function icon(Comp, color, size = 256) {
  let svg = ReactDOMServer.renderToStaticMarkup(
    React.createElement(Comp, { color, size: String(size) })
  );
  if (!/xmlns=/.test(svg)) svg = svg.replace("<svg", '<svg xmlns="http://www.w3.org/2000/svg"');
  const png = execFileSync("rsvg-convert", ["-w", String(size), "-h", String(size)],
    { input: Buffer.from(svg), maxBuffer: 1024 * 1024 * 16 });
  return "image/png;base64," + png.toString("base64");
}
const mkShadow = () => ({ type:"outer", color:"000000", blur:10, offset:3, angle:135, opacity:0.14 });

(async () => {
  const pres = new pptxgen();
  pres.layout = "LAYOUT_WIDE";
  pres.author = "SDD Toolkit";
  pres.title  = "Spec-Driven Development";

  // ─── Preload icons ────────────────────────────────────────────
  const ic = {
    redo:    await icon(FA.FaRedo,             "#E9A23B"),
    expand:  await icon(FA.FaArrowsAlt,        "#E9A23B"),
    question:await icon(FA.FaQuestion,         "#E9A23B"),
    robot:   await icon(FA.FaRobot,            "#E9A23B"),
    cost:    await icon(FA.FaMoneyBillWave,    "#D64045"),
    clock:   await icon(FA.FaClock,            "#D64045"),
    bolt:    await icon(FA.FaBolt,             "#D64045"),
    check:   await icon(FA.FaCheckCircle,      "#2EC4B6"),
    lock:    await icon(FA.FaLock,             "#FFFFFF"),
    userW:   await icon(FA.FaUserTie,          "#FFFFFF"),
    userN:   await icon(FA.FaUserTie,          "#12203F"),
    codeW:   await icon(FA.FaLaptopCode,       "#FFFFFF"),
    fileT:   await icon(FA.FaFileAlt,          "#2EC4B6"),
    fileW:   await icon(FA.FaFileAlt,          "#FFFFFF"),
    shieldW: await icon(FA.FaShieldAlt,        "#FFFFFF"),
    rocketW: await icon(FA.FaRocket,           "#FFFFFF"),
    rocketT: await icon(FA.FaRocket,           "#2EC4B6"),
    eye:     await icon(FA.FaSearch,           "#FFFFFF"),
    arrow:   await icon(FA.FaArrowRight,       "#9BAEC8"),
    arrowT:  await icon(FA.FaArrowRight,       "#2EC4B6"),
    flagW:   await icon(FA.FaFlagCheckered,    "#FFFFFF"),
    warn:    await icon(FA.FaExclamationTriangle, "#E9A23B"),
    warnR:   await icon(FA.FaExclamationTriangle, "#D64045"),
    tasks:   await icon(FA.FaTasks,            "#FFFFFF"),
    chartB:  await icon(FA.FaChartBar,         "#FFFFFF"),
    pencil:  await icon(FA.FaPencilAlt,        "#FFFFFF"),
    search:  await icon(FA.FaSearchPlus,       "#FFFFFF"),
    cog:     await icon(FA.FaCog,              "#FFFFFF"),
    scroll:  await icon(FA.FaScroll,           "#FFFFFF"),
    check2:  await icon(FA.FaClipboardCheck,   "#FFFFFF"),
    star:    await icon(FA.FaStar,             "#E9A23B"),
  };

  // ─── Shared helpers ───────────────────────────────────────────
  function footer(slide, n, dark) {
    const c = dark ? "5F7DA8" : MUTED;
    slide.addText("Spec-Driven Development", {
      x:0.6, y:H-0.42, w:6, h:0.3, fontSize:9, color:c, fontFace:BFONT, align:"left", margin:0
    });
    slide.addText(`${n}`, {
      x:W-1.0, y:H-0.42, w:0.4, h:0.3, fontSize:9, color:c, fontFace:BFONT, align:"right", margin:0
    });
  }
  function kicker(slide, text, color) {
    slide.addText(text.toUpperCase(), {
      x:0.65, y:0.48, w:12, h:0.32, fontSize:11.5, bold:true, color:color||TEAL,
      charSpacing:3.5, fontFace:BFONT, margin:0
    });
  }
  function heading(slide, text, color) {
    slide.addText(text, {
      x:0.65, y:0.82, w:12, h:0.95, fontSize:34, bold:true, color:color||INK,
      fontFace:HFONT, margin:0
    });
  }
  function sub(slide, text, color) {
    slide.addText(text, {
      x:0.65, y:1.72, w:12, h:0.38, fontSize:14, color:color||MUTED, fontFace:BFONT, margin:0
    });
  }
  // Accent circle with icon
  function circle(slide, iconData, bg, x, y, r) {
    slide.addShape(pres.shapes.OVAL,
      { x, y, w:r, h:r, fill:{color:bg}, line:{type:"none"} });
    const pad = r * 0.22;
    slide.addImage({ data:iconData, x:x+pad, y:y+pad, w:r-pad*2, h:r-pad*2 });
  }
  // Gate badge
  function gateBadge(slide, label, x, y) {
    slide.addShape(pres.shapes.RECTANGLE,
      { x, y, w:2.4, h:0.36, fill:{color:"1A3A6B"}, line:{color:TEAL,width:1}, rectRadius:0.05 });
    slide.addImage({ data:ic.lock, x:x+0.12, y:y+0.06, w:0.24, h:0.24 });
    slide.addText("APPROVAL GATE", { x:x+0.44, y:y+0.04, w:1.85, h:0.3,
      fontSize:9, bold:true, color:TEAL, charSpacing:1, fontFace:BFONT, margin:0 });
  }

  // ══════════════════════════════════════════════════════════════
  // SLIDE 1 — TITLE
  // ══════════════════════════════════════════════════════════════
  let s = pres.addSlide();
  s.background = { color: NAVY };
  // decorative circles
  s.addShape(pres.shapes.OVAL, { x:11.2, y:-0.5, w:2.8, h:2.8, fill:{color:TEAL, transparency:85}, line:{type:"none"} });
  s.addShape(pres.shapes.OVAL, { x:12.1, y:1.5,  w:1.8, h:1.8, fill:{color:AMBER, transparency:85}, line:{type:"none"} });
  s.addShape(pres.shapes.OVAL, { x:-0.8, y:5.8,  w:2.4, h:2.4, fill:{color:TEAL, transparency:88}, line:{type:"none"} });

  s.addText("FOR LEADERSHIP", {
    x:0.9, y:2.0, w:8, h:0.36, fontSize:12.5, bold:true, color:TEAL,
    charSpacing:4, fontFace:BFONT, margin:0
  });
  s.addText("Spec-Driven Development", {
    x:0.85, y:2.42, w:12, h:1.45, fontSize:58, bold:true, color:"FFFFFF",
    fontFace:HFONT, margin:0
  });
  s.addText("Shipping the right thing — predictably.", {
    x:0.9, y:3.95, w:11, h:0.65, fontSize:24, italic:true, color:ICE, fontFace:HFONT, margin:0
  });
  s.addShape(pres.shapes.LINE, { x:0.95, y:4.8, w:2.2, h:0, line:{color:AMBER, width:2.5} });
  s.addText(
    "How we turn business requirements into working software — with humans approving every critical step." +
    "  Especially important now that AI can build fast: we need to make sure that speed points in the right direction.",
    { x:0.9, y:5.0, w:11.4, h:0.9, fontSize:14.5, color:ICE, fontFace:BFONT, margin:0 }
  );

  // ══════════════════════════════════════════════════════════════
  // SLIDE 2 — THE PROBLEM (fuller cards)
  // ══════════════════════════════════════════════════════════════
  s = pres.addSlide();
  s.background = { color: LIGHT };
  kicker(s, "The problem today");
  heading(s, "Four patterns that derail most software projects");
  sub(s, "These four patterns show up in nearly every team — and each one compounds the others.");

  const pains = [
    [ic.redo,     "Expensive rework",
     "We build a feature, ship it, and then discover it wasn't what the business actually needed — and do it again. On average, 40–50% of total project effort goes to work that gets thrown away or redone.",
     "Every rework cycle: wasted time, delayed roadmap, team morale hit."],
    [ic.question, "Fuzzy requirements",
     "\"What to build\" and \"why it matters\" live in Slack threads, meeting notes, and people's heads — not in one single, approved place. Everyone has a slightly different understanding.",
     "Result: engineers build confidently in the wrong direction."],
    [ic.expand,   "Silent scope creep",
     "Work quietly expands mid-build. New ideas get added, edges cases multiply, but there's no formal decision point — so the timeline slips with no clear explanation for why.",
     "Nobody is to blame, but everyone suffers the delay."],
    [ic.robot,    "AI without guardrails",
     "AI can now write code in hours that would have taken days. That's powerful — but speed in the wrong direction is more damaging, not less. AI amplifies the cost of unclear requirements.",
     "Faster wrong = harder to recover."],
  ];
  const cw = 5.85, cgap = 0.3, cy = 2.3;
  pains.forEach((p, i) => {
    const x = 0.65 + (i % 2) * (cw + cgap);
    const y = cy + Math.floor(i / 2) * 2.35;
    s.addShape(pres.shapes.RECTANGLE,
      { x, y, w:cw, h:2.2, fill:{color:CARD}, line:{color:BORDER, width:1}, shadow:mkShadow() });
    s.addShape(pres.shapes.RECTANGLE,
      { x, y, w:0.1, h:2.2, fill:{color:AMBER}, line:{type:"none"} });
    circle(s, p[0], "FEF3DC", x+0.35, y+0.35, 0.62);
    s.addText(p[1], { x:x+1.2, y:y+0.3,  w:4.45, h:0.5, fontSize:17, bold:true, color:INK, fontFace:HFONT, margin:0 });
    s.addText(p[2], { x:x+1.2, y:y+0.82, w:4.45, h:0.7, fontSize:11.5, color:MUTED, fontFace:BFONT, margin:0 });
    s.addShape(pres.shapes.LINE, { x:x+1.2, y:y+1.58, w:4.4, h:0, line:{color:BORDER, width:0.75} });
    s.addText(p[3], { x:x+1.2, y:y+1.62, w:4.45, h:0.45, fontSize:11, italic:true, color:RED, fontFace:BFONT, margin:0 });
  });
  footer(s, 2, false);

  // ══════════════════════════════════════════════════════════════
  // SLIDE 3 — WHY NOW? THE COST OF THE STATUS QUO
  // ══════════════════════════════════════════════════════════════
  s = pres.addSlide();
  s.background = { color: NAVY };
  kicker(s, "Why this matters now", AMBER);
  heading(s, "The cost of the status quo is going up — not down", "FFFFFF");
  sub(s, "Three reasons this is urgent in 2025.", ICE);

  const stakes = [
    [ic.cost,  "40–50% of rework",
     "Industry research consistently finds that 40–50% of all software rework is traceable to unclear or misunderstood requirements at the start. This isn't a code quality problem — it's a communication problem.",
     "→  The fix is a better process before the first line of code, not better testing afterward."],
    [ic.bolt,  "AI makes it 10× faster — and 10× riskier",
     "A team using AI today can build in one week what used to take a month. That's a force multiplier — but only if the direction is right. Unclear requirements + AI speed = very expensive wrong turns, very fast.",
     "→  Speed amplifies both good direction and bad direction equally."],
    [ic.clock, "No signed-off record",
     "Right now, there is often no single moment where the business said \"yes, build exactly this.\" When the wrong thing ships, there's no accountability — and no learning. The same patterns repeat next sprint.",
     "→  SDD creates that moment. And it creates the paper trail to learn from."],
  ];
  const sw = 3.85, sgap = 0.28;
  const stot = 3*sw + 2*sgap;
  let sx2 = (W - stot) / 2;
  stakes.forEach((st, i) => {
    const x = sx2 + i * (sw + sgap);
    const y = 2.5;
    s.addShape(pres.shapes.RECTANGLE,
      { x, y, w:sw, h:4.5, fill:{color:NAVY3}, line:{color:"44608F", width:1.25}, shadow:mkShadow() });
    s.addShape(pres.shapes.RECTANGLE,
      { x, y, w:sw, h:0.12, fill:{color:RED}, line:{type:"none"} });
    circle(s, st[0], "3A1C1E", x+0.35, y+0.35, 0.72);
    s.addText(st[1], { x:x+0.35, y:y+1.22, w:sw-0.5, h:0.6, fontSize:18, bold:true, color:"FFFFFF", fontFace:HFONT, margin:0 });
    s.addText(st[2], { x:x+0.35, y:y+1.9, w:sw-0.5, h:1.55, fontSize:12.5, color:ICE, fontFace:BFONT, margin:0 });
    s.addShape(pres.shapes.LINE, { x:x+0.35, y:y+3.52, w:sw-0.6, h:0, line:{color:"44608F", width:0.75} });
    s.addText(st[3], { x:x+0.35, y:y+3.6, w:sw-0.5, h:0.75, fontSize:11.5, italic:true, color:TEAL, fontFace:BFONT, margin:0 });
  });
  footer(s, 3, true);

  // ══════════════════════════════════════════════════════════════
  // SLIDE 4 — WHAT SDD IS
  // ══════════════════════════════════════════════════════════════
  s = pres.addSlide();
  s.background = { color: NAVY };
  kicker(s, "The idea, in one line", TEAL);
  s.addText([
    { text: "Agree on ", options: { color: "FFFFFF" } },
    { text: "what & why", options: { color: TEAL } },
    { text: " first.", options: { color: "FFFFFF", breakLine: true } },
    { text: "Then build against an ", options: { color: "FFFFFF" } },
    { text: "approved spec", options: { color: AMBER } },
    { text: " —", options: { color: "FFFFFF", breakLine: true } },
    { text: "with ", options: { color: "FFFFFF" } },
    { text: "humans signing off", options: { color: TEAL } },
    { text: " at every critical step.", options: { color: "FFFFFF" } },
  ], { x:0.85, y:1.55, w:12.0, h:2.75, fontSize:33, bold:true, fontFace:HFONT, lineSpacingMultiple:1.18, margin:0 });

  const pillars = [
    [ic.pencil,  "Requirement-first",
     "The spec is written in business language — WHAT and WHY only. No tech jargon. A business owner can read it, own it, and approve it without an engineer in the room."],
    [ic.shieldW, "Approval-gated",
     "Three human checkpoints: approve the spec, approve the plan, say go to build. Work cannot advance past a gate without an explicit sign-off. No silent progress."],
    [ic.rocketW, "Fully traceable",
     "Every task traces back to the spec. Every line of code traces back to a task. At any moment, you can answer \"why was this built?\" with a document."],
  ];
  pillars.forEach((p, i) => {
    const x = 0.85 + i * 4.05;
    const y = 4.75;
    s.addShape(pres.shapes.RECTANGLE,
      { x, y, w:3.75, h:2.35, fill:{color:NAVY3}, line:{color:"44608F", width:1.25} });
    circle(s, p[0], "2C4C82", x+0.35, y+0.35, 0.72);
    s.addText(p[1], { x:x+1.25, y:y+0.38, w:2.35, h:0.55, fontSize:17, bold:true, color:"FFFFFF", fontFace:HFONT, margin:0 });
    s.addText(p[2], { x:x+0.35, y:y+1.2,  w:3.22, h:1.05, fontSize:11.5, color:"D8E3F5", fontFace:BFONT, margin:0 });
  });
  footer(s, 4, true);

  // ══════════════════════════════════════════════════════════════
  // SLIDE 5 — PIPELINE OVERVIEW (compact, with 2-line descriptions)
  // ══════════════════════════════════════════════════════════════
  s = pres.addSlide();
  s.background = { color: LIGHT };
  kicker(s, "How it flows");
  heading(s, "Every feature follows the same 7-step path");
  sub(s, "Each step produces a written artifact. The next step cannot start until the previous one is complete.");

  const steps = [
    ["1", "Constitution",  "Set the ground rules\nall features must respect.",    false, true  ],
    ["2", "Specify",       "Write what & why in\nbusiness language. BO approves.", true,  true  ],
    ["3", "Clarify",       "Surface ambiguities\nbefore planning starts.",         true,  false ],
    ["4", "Plan",          "Engineering designs\nhow it will be built.",           false, true  ],
    ["5", "Tasks",         "Break the plan into\ntracked, verifiable steps.",      false, false ],
    ["6", "Analyze",       "Cross-check: spec vs\nplan vs tasks — no gaps.",       false, false ],
    ["7", "Implement",     "Build, test, and ship\nagainst the approved spec.",    false, true  ],
  ];
  const n = steps.length;
  const colW = 1.68, colGap = 0.12;
  const totalW = n * colW + (n-1) * colGap;
  let sx = (W - totalW) / 2;
  const sy = 2.45;
  const cardH = 3.2;

  steps.forEach((st, i) => {
    const x = sx + i * (colW + colGap);
    const accent = st[3] ? TEAL : NAVY;
    s.addShape(pres.shapes.RECTANGLE,
      { x, y:sy, w:colW, h:cardH, fill:{color:CARD}, line:{color:BORDER, width:1}, shadow:mkShadow() });
    s.addShape(pres.shapes.RECTANGLE,
      { x, y:sy, w:colW, h:0.12, fill:{color:accent}, line:{type:"none"} });
    // number circle
    s.addShape(pres.shapes.OVAL,
      { x:x+colW/2-0.38, y:sy+0.25, w:0.76, h:0.76, fill:{color:accent}, line:{type:"none"} });
    s.addText(st[0], { x:x+colW/2-0.38, y:sy+0.25, w:0.76, h:0.76,
      fontSize:24, bold:true, color:"FFFFFF", align:"center", valign:"middle", fontFace:HFONT, margin:0 });
    // name
    s.addText(st[1], { x, y:sy+1.16, w:colW, h:0.44,
      fontSize:14.5, bold:true, color:INK, align:"center", fontFace:HFONT, margin:0 });
    // description
    s.addText(st[2], { x:x+0.08, y:sy+1.6, w:colW-0.16, h:1.35,
      fontSize:10.5, color:MUTED, align:"center", fontFace:BFONT, margin:0 });
    // gate badge below
    if (st[4]) {
      s.addImage({ data:ic.lock, x:x+colW/2-0.13, y:sy+cardH+0.12, w:0.26, h:0.26 });
    }
    // arrow
    if (i < n-1) {
      s.addImage({ data:ic.arrow, x:x+colW+colGap/2-0.12, y:sy+0.6, w:0.24, h:0.24 });
    }
  });

  // Legend
  const lx = sx;
  const ly = sy + cardH + 0.65;
  s.addShape(pres.shapes.OVAL, { x:lx,     y:ly+0.05, w:0.22, h:0.22, fill:{color:TEAL}, line:{type:"none"} });
  s.addText("Business owner is directly involved", { x:lx+0.32, y:ly, w:4.5, h:0.32, fontSize:11.5, bold:true, color:INK, fontFace:BFONT, margin:0 });
  s.addShape(pres.shapes.OVAL, { x:lx+5.2, y:ly+0.05, w:0.22, h:0.22, fill:{color:NAVY}, line:{type:"none"} });
  s.addText("Engineering executes",               { x:lx+5.5, y:ly, w:3.5, h:0.32, fontSize:11.5, color:MUTED, fontFace:BFONT, margin:0 });
  s.addImage({ data:ic.lock, x:lx+9.2, y:ly+0.02, w:0.24, h:0.24 });
  s.addText("Approval gate — work blocks here",   { x:lx+9.55, y:ly, w:3.5, h:0.32, fontSize:11.5, color:MUTED, fontFace:BFONT, margin:0 });
  footer(s, 5, false);

  // ══════════════════════════════════════════════════════════════
  // SLIDE 6 — BUSINESS OWNER PHASES (1-3) IN DETAIL
  // ══════════════════════════════════════════════════════════════
  s = pres.addSlide();
  s.background = { color: LIGHT };
  kicker(s, "The steps you're directly involved in", TEAL);
  heading(s, "Phases 1–3: where business strategy meets the process");
  sub(s, "These three steps happen before any engineering work begins. Your involvement here prevents every costly surprise later.");

  const boPhases = [
    {
      n:"1", name:"Constitution",
      icon: ic.scroll,
      accent: NAVY, circleColor:"1B2E54",
      desc: "Before any feature begins, the team documents the principles that govern the entire product: design standards, technical constraints, compliance rules, what we will and won't do. This document is written once and applies to every feature that follows.",
      artifact: "constitution.md",
      owner: "PM + Tech Lead",
      gate: false,
      why:"Without this, every team member makes their own judgment calls. Inconsistency builds up silently across features.",
    },
    {
      n:"2", name:"Specify",
      icon: ic.pencil,
      accent: TEAL, circleColor:"227F79",
      desc: "The business owner (or PM) writes — in plain English — what the feature should do, why it matters to the user, and how you'll know it's done. No technical language. This spec is the source of truth for everything that follows.",
      artifact: "spec.md",
      owner: "Business Owner / PM",
      gate: true,
      why:"Engineering cannot start planning until this spec is formally approved. A vague spec produces a vague product.",
    },
    {
      n:"3", name:"Clarify",
      icon: ic.search,
      accent: TEAL, circleColor:"227F79",
      desc: "Before engineering plans anything, the team reviews the spec together to surface any ambiguity or unstated assumption. Questions are answered, edge cases are added to the spec. This step typically takes one meeting.",
      artifact: "Updated spec.md",
      owner: "PM + Engineering",
      gate: false,
      why:"Ambiguity caught here costs 30 minutes. Ambiguity discovered mid-build costs days and rework.",
    },
  ];
  const pw = 3.85, pgap = 0.3;
  const ptot = 3*pw + 2*pgap;
  const px0 = (W - ptot) / 2;
  const py = 2.3, ph = 4.75;

  boPhases.forEach((p, i) => {
    const x = px0 + i * (pw + pgap);
    s.addShape(pres.shapes.RECTANGLE,
      { x, y:py, w:pw, h:ph, fill:{color:CARD}, line:{color:BORDER, width:1}, shadow:mkShadow() });
    // colored header band
    s.addShape(pres.shapes.RECTANGLE,
      { x, y:py, w:pw, h:1.05, fill:{color:p.accent}, line:{type:"none"} });
    circle(s, p.icon, p.circleColor, x+0.35, py+0.22, 0.62);
    s.addText(`PHASE ${p.n}`, { x:x+1.15, y:py+0.2, w:pw-1.25, h:0.28,
      fontSize:10, bold:true, color:"FFFFFF", charSpacing:2, fontFace:BFONT, margin:0 });
    s.addText(p.name, { x:x+1.15, y:py+0.5, w:pw-1.25, h:0.48,
      fontSize:20, bold:true, color:"FFFFFF", fontFace:HFONT, margin:0 });
    // description
    s.addText(p.desc, { x:x+0.3, y:py+1.2, w:pw-0.5, h:1.72,
      fontSize:12, color:INK, fontFace:BFONT, margin:0 });
    // divider
    s.addShape(pres.shapes.LINE, { x:x+0.3, y:py+2.98, w:pw-0.45, h:0, line:{color:BORDER, width:0.75} });
    // artifact
    s.addText("PRODUCES", { x:x+0.3, y:py+3.05, w:1.1, h:0.24,
      fontSize:8, bold:true, color:MUTED, charSpacing:1.5, fontFace:BFONT, margin:0 });
    s.addImage({ data:ic.fileT, x:x+1.42, y:py+3.04, w:0.2, h:0.2 });
    s.addText(p.artifact, { x:x+1.68, y:py+3.03, w:pw-1.9, h:0.26,
      fontSize:11, bold:true, color:INK, fontFace:BFONT, margin:0 });
    // owner
    s.addText("OWNER", { x:x+0.3, y:py+3.32, w:1.0, h:0.24,
      fontSize:8, bold:true, color:MUTED, charSpacing:1.5, fontFace:BFONT, margin:0 });
    s.addText(p.owner, { x:x+1.42, y:py+3.3, w:pw-1.6, h:0.26,
      fontSize:11, color:INK, fontFace:BFONT, margin:0 });
    // why / gate block (single unified block)
    const gateColor = p.gate ? "E4F8F7" : "F4F6FB";
    const gateBorder = p.gate ? TEAL : BORDER;
    s.addShape(pres.shapes.RECTANGLE,
      { x:x+0.3, y:py+3.65, w:pw-0.45, h:0.95,
        fill:{color:gateColor}, line:{color:gateBorder, width: p.gate ? 1 : 0.5} });
    if (p.gate) {
      s.addImage({ data:ic.lock, x:x+0.42, y:py+3.72, w:0.22, h:0.22 });
      s.addText("APPROVAL GATE", { x:x+0.72, y:py+3.69, w:1.8, h:0.26,
        fontSize:9, bold:true, color:TEAL, charSpacing:1, fontFace:BFONT, margin:0 });
      s.addText(p.why, { x:x+0.42, y:py+3.96, w:pw-0.62, h:0.52,
        fontSize:10, italic:true, color:TEAL, fontFace:BFONT, margin:0 });
    } else {
      s.addText(p.why, { x:x+0.42, y:py+3.72, w:pw-0.62, h:0.78,
        fontSize:10.5, italic:true, color:MUTED, fontFace:BFONT, margin:0 });
    }
  });
  footer(s, 6, false);

  // ══════════════════════════════════════════════════════════════
  // SLIDE 7 — ENGINEERING PHASES (4-7) IN DETAIL
  // ══════════════════════════════════════════════════════════════
  s = pres.addSlide();
  s.background = { color: LIGHT };
  kicker(s, "What engineering does with your approved spec");
  s.addText("Phases 4–7: approved spec to shipped software", {
    x:0.65, y:0.82, w:12, h:0.95, fontSize:34, bold:true, color:INK, fontFace:HFONT, margin:0
  });
  sub(s, "Once the spec is approved, engineering takes over. You remain a sign-off at gate 2 (plan) before any build starts.");

  const engPhases = [
    {
      n:"4", name:"Plan",
      icon: ic.chartB,
      accent: NAVY, circleColor:"1B2E54",
      desc: "Engineering translates the approved spec into a technical design: architecture decisions, data model, API contracts, and sequencing. This plan is written for tech leads to review — not for the business owner to approve line by line.",
      artifact: "plan.md",
      owner: "Tech Lead",
      gate: true,
      why:"Plan approved before any tasks are created. Prevents building in the wrong technical direction.",
    },
    {
      n:"5", name:"Tasks",
      icon: ic.tasks,
      accent: NAVY, circleColor:"1B2E54",
      desc: "The plan is broken into small, concrete, independently verifiable tasks. Each task maps to a requirement in the spec. This list becomes the single source of truth for what's done and what remains — visible to anyone.",
      artifact: "tasks.md",
      owner: "Engineering",
      gate: false,
      why:"A task list you can track is how 'we're working on it' becomes 'we're 70% done' with evidence.",
    },
    {
      n:"6", name:"Analyze",
      icon: ic.check2,
      accent: NAVY, circleColor:"1B2E54",
      desc: "An automated cross-check: do the tasks cover every requirement in the spec? Does the plan contradict the constitution? Are there gaps the team missed? This step catches alignment issues before they become bugs.",
      artifact: "analysis.md",
      owner: "Tech Lead",
      gate: false,
      why:"Catches 'we forgot about X' at the planning stage, not after it ships.",
    },
    {
      n:"7", name:"Implement",
      icon: ic.cog,
      accent: TEAL, circleColor:"227F79",
      desc: "With an explicit 'go' from the business owner, engineering builds, tests, and ships. Every commit traces back to a task. Every task traces back to the spec. Scope is fixed — any new idea becomes a new spec.",
      artifact: "Shipped feature",
      owner: "Engineering",
      gate: true,
      why:"Explicit GO required. Scope is locked to the approved spec.",
    },
  ];
  const epw = 2.88, epgap = 0.26;
  const eptot = 4*epw + 3*epgap;
  const epx0 = (W - eptot) / 2;
  const epy = 2.45, eph = 4.6;

  engPhases.forEach((p, i) => {
    const x = epx0 + i * (epw + epgap);
    s.addShape(pres.shapes.RECTANGLE,
      { x, y:epy, w:epw, h:eph, fill:{color:CARD}, line:{color:BORDER, width:1}, shadow:mkShadow() });
    s.addShape(pres.shapes.RECTANGLE,
      { x, y:epy, w:epw, h:1.05, fill:{color:p.accent}, line:{type:"none"} });
    circle(s, p.icon, p.circleColor, x+0.3, epy+0.22, 0.6);
    s.addText(`PHASE ${p.n}`, { x:x+1.1, y:epy+0.18, w:epw-1.2, h:0.28,
      fontSize:9.5, bold:true, color:"FFFFFF", charSpacing:2, fontFace:BFONT, margin:0 });
    s.addText(p.name, { x:x+1.1, y:epy+0.5, w:epw-1.2, h:0.46,
      fontSize:18.5, bold:true, color:"FFFFFF", fontFace:HFONT, margin:0 });
    // description
    s.addText(p.desc, { x:x+0.28, y:epy+1.18, w:epw-0.44, h:1.88,
      fontSize:11, color:INK, fontFace:BFONT, margin:0 });
    // divider
    s.addShape(pres.shapes.LINE, { x:x+0.28, y:epy+3.12, w:epw-0.38, h:0, line:{color:BORDER, width:0.75} });
    // artifact
    s.addText("PRODUCES", { x:x+0.28, y:epy+3.18, w:1.0, h:0.24,
      fontSize:7.5, bold:true, color:MUTED, charSpacing:1.5, fontFace:BFONT, margin:0 });
    s.addImage({ data:ic.fileT, x:x+1.32, y:epy+3.17, w:0.2, h:0.2 });
    s.addText(p.artifact, { x:x+1.56, y:epy+3.15, w:epw-1.75, h:0.26,
      fontSize:10.5, bold:true, color:INK, fontFace:BFONT, margin:0 });
    // owner
    s.addText("OWNER", { x:x+0.28, y:epy+3.44, w:1.0, h:0.24,
      fontSize:7.5, bold:true, color:MUTED, charSpacing:1.5, fontFace:BFONT, margin:0 });
    s.addText(p.owner, { x:x+1.32, y:epy+3.42, w:epw-1.5, h:0.26,
      fontSize:10.5, color:INK, fontFace:BFONT, margin:0 });
    // why / gate unified block
    const egc = p.gate ? "E4F8F7" : "F4F6FB";
    const egb = p.gate ? TEAL : BORDER;
    s.addShape(pres.shapes.RECTANGLE,
      { x:x+0.28, y:epy+3.76, w:epw-0.38, h:0.72,
        fill:{color:egc}, line:{color:egb, width: p.gate ? 1 : 0.5} });
    if (p.gate) {
      s.addImage({ data:ic.lock, x:x+0.36, y:epy+3.81, w:0.2, h:0.2 });
      s.addText("APPROVAL GATE", { x:x+0.62, y:epy+3.79, w:1.6, h:0.24,
        fontSize:8.5, bold:true, color:TEAL, charSpacing:1, fontFace:BFONT, margin:0 });
      s.addText(p.why, { x:x+0.36, y:epy+4.0, w:epw-0.52, h:0.4,
        fontSize:9, italic:true, color:TEAL, fontFace:BFONT, margin:0 });
    } else {
      s.addText(p.why, { x:x+0.36, y:epy+3.8, w:epw-0.52, h:0.62,
        fontSize:9.5, italic:true, color:MUTED, fontFace:BFONT, margin:0 });
    }
  });
  footer(s, 7, false);

  // ══════════════════════════════════════════════════════════════
  // SLIDE 8 — THE 3 GATES (fuller, fill the space)
  // ══════════════════════════════════════════════════════════════
  s = pres.addSlide();
  s.background = { color: NAVY };
  kicker(s, "Control points", TEAL);
  heading(s, "Three approval gates keep humans in charge", "FFFFFF");
  sub(s, "Work cannot advance past a gate without an explicit sign-off. If the spec isn't right, nothing moves. If the plan isn't right, nothing is built.", ICE);

  const gates = [
    {
      n:"1", title:"Spec approved",
      who:"Business Owner / PM",
      desc:"The business owner reads the spec and confirms: \"Yes, this is what we want and why we want it. I'm comfortable with engineering planning against this.\" No engineering work has started yet.",
      when:"After Specify + Clarify, before Plan",
      what:"If the spec is wrong, this is the cheapest possible moment to fix it — before anyone has designed or built anything.",
      consequence:"Without this gate, engineering makes assumptions about what you want. Some will be right. Some won't.",
    },
    {
      n:"2", title:"Plan approved",
      who:"Tech Lead (+ PM review)",
      desc:"Engineering presents how they'll build it: the architecture, the data design, the key risks. The tech lead signs off that the approach is sound, safe, and achievable within scope.",
      when:"After Plan, before Tasks are created",
      what:"If the plan is architecturally unsound, this is the moment to redesign — before any code is written.",
      consequence:"Without this gate, you may get code that technically works but is impossible to maintain or extend.",
    },
    {
      n:"3", title:"Go to build",
      who:"Business Owner",
      desc:"An explicit, documented \"go\" signal before the first line of code is written. The spec is locked. Any new idea that comes up during implementation becomes a new feature — it doesn't silently expand the current one.",
      when:"After Tasks + Analyze, before Implement",
      what:"This is the moment where scope is frozen and accountability is established. You approved what gets built.",
      consequence:"Without this gate, scope creeps, deadlines slip, and nobody is sure exactly what was agreed to.",
    },
  ];
  const gw = 3.85, ggap = 0.28;
  const gtot = 3*gw + 2*ggap;
  const gx0 = (W - gtot) / 2;
  const gy = 2.5, gh = 4.55;

  gates.forEach((g, i) => {
    const x = gx0 + i * (gw + ggap);
    s.addShape(pres.shapes.RECTANGLE,
      { x, y:gy, w:gw, h:gh, fill:{color:NAVY3}, line:{color:"44608F", width:1.25}, shadow:mkShadow() });
    s.addShape(pres.shapes.RECTANGLE,
      { x, y:gy, w:gw, h:0.12, fill:{color:TEAL}, line:{type:"none"} });
    circle(s, ic.lock, "2C6B66", x+0.35, gy+0.28, 0.72);
    s.addText(`GATE ${g.n}`, { x:x+1.25, y:gy+0.28, w:gw-1.4, h:0.28,
      fontSize:10, bold:true, color:TEAL, charSpacing:2, fontFace:BFONT, margin:0 });
    s.addText(g.title, { x:x+1.25, y:gy+0.6, w:gw-1.4, h:0.5,
      fontSize:19, bold:true, color:"FFFFFF", fontFace:HFONT, margin:0 });
    s.addText(`Who approves: ${g.who}`, { x:x+0.35, y:gy+1.2, w:gw-0.55, h:0.28,
      fontSize:11, italic:true, color:ICE, fontFace:BFONT, margin:0 });
    s.addText(g.desc, { x:x+0.35, y:gy+1.55, w:gw-0.55, h:1.22,
      fontSize:11.5, color:"D8E3F5", fontFace:BFONT, margin:0 });
    s.addShape(pres.shapes.LINE, { x:x+0.35, y:gy+2.85, w:gw-0.55, h:0, line:{color:"44608F", width:0.75} });
    s.addText(`WHEN: ${g.when}`, { x:x+0.35, y:gy+2.92, w:gw-0.55, h:0.26,
      fontSize:10, bold:true, color:AMBER, fontFace:BFONT, margin:0 });
    s.addText(g.what, { x:x+0.35, y:gy+3.22, w:gw-0.55, h:0.58,
      fontSize:11, color:ICE, fontFace:BFONT, margin:0 });
    s.addShape(pres.shapes.RECTANGLE,
      { x:x+0.35, y:gy+3.88, w:gw-0.55, h:0.55, fill:{color:"0D1A35"}, line:{type:"none"} });
    s.addImage({ data:ic.warnR, x:x+0.45, y:gy+3.93, w:0.26, h:0.26 });
    s.addText(g.consequence, { x:x+0.8, y:gy+3.9, w:gw-1.0, h:0.52,
      fontSize:10, italic:true, color:"CC7A7C", fontFace:BFONT, margin:0 });
  });
  footer(s, 8, true);

  // ══════════════════════════════════════════════════════════════
  // SLIDE 9 — WHO OWNS WHAT
  // ══════════════════════════════════════════════════════════════
  s = pres.addSlide();
  s.background = { color: LIGHT };
  kicker(s, "Clear ownership");
  heading(s, "Everyone owns the part they're best at");
  sub(s, "SDD doesn't ask the business owner to write code or engineers to define product strategy. Each person stays in their lane.");

  function ownerCol2(x, iconData, accent, headerBg, role, sub2, items) {
    s.addShape(pres.shapes.RECTANGLE,
      { x, y:2.35, w:5.95, h:4.75, fill:{color:CARD}, line:{color:BORDER, width:1}, shadow:mkShadow() });
    s.addShape(pres.shapes.RECTANGLE,
      { x, y:2.35, w:5.95, h:1.05, fill:{color:headerBg}, line:{type:"none"} });
    circle(s, iconData, accent, x+0.35, 2.52, 0.72);
    s.addText(role, { x:x+1.25, y:2.5, w:4.5, h:0.56,
      fontSize:22, bold:true, color:"FFFFFF", fontFace:HFONT, margin:0 });
    s.addText(sub2, { x:x+1.25, y:3.0, w:4.5, h:0.3,
      fontSize:13, italic:true, color:"FFFFFF", fontFace:BFONT, margin:0, alpha:0.8 });
    let iy = 3.6;
    items.forEach((it) => {
      circle(s, ic.check, "E6F8F7", x+0.4, iy+0.02, 0.38);
      s.addText(it[0], { x:x+0.95, y:iy+0.04, w:4.8, h:0.35,
        fontSize:14.5, bold:true, color:INK, fontFace:BFONT, margin:0 });
      s.addText(it[1], { x:x+0.95, y:iy+0.41, w:4.85, h:0.32,
        fontSize:11, color:MUTED, fontFace:BFONT, margin:0 });
      iy += 0.88;
    });
  }
  ownerCol2(0.65, ic.userW, "1C6B66", TEAL, "Business Owner / PM", "Owns the WHAT and the WHY", [
    ["Set the ground rules",       "Define the principles the product must follow."],
    ["Write & approve the spec",   "Plain English — no technical jargon required."],
    ["Answer clarifying questions","One meeting to remove any ambiguity from the spec."],
    ["Approve the plan & go",      "Two sign-offs before a single line of code is written."],
  ]);
  ownerCol2(6.7, ic.codeW, "1B2E54", NAVY, "Engineering Team", "Owns the HOW", [
    ["Translate spec into a plan",  "Architecture, data model, key technical decisions."],
    ["Break plan into tasks",       "Tracked, verifiable steps mapped to requirements."],
    ["Build against the spec",      "Scope is fixed; new ideas become new specs."],
    ["Flag conflicts early",        "If spec and plan don't align, raise it before building."],
  ]);
  footer(s, 9, false);

  // ══════════════════════════════════════════════════════════════
  // SLIDE 10 — BEFORE / AFTER
  // ══════════════════════════════════════════════════════════════
  s = pres.addSlide();
  s.background = { color: LIGHT };
  kicker(s, "The shift");
  heading(s, "From ad-hoc to accountable");
  sub(s, "The same team, the same people — just a different process.");

  const beforeItems = [
    ["Requirements scattered in chats",   "No single source of truth. Everyone's working from a slightly different version."],
    ["\"Is this done?\" has no clear answer", "Progress is invisible until it's finished — or late."],
    ["Scope grows without a decision",    "Features expand silently. Nobody approved the expansion."],
    ["AI writes code nobody specced",     "The speed is there, but it's building against assumptions."],
    ["Rework discovered after shipping",  "The most expensive moment to find a problem."],
  ];
  const afterItems = [
    ["One approved spec — written down",  "Everybody reads the same document. Disagreements surface early, not late."],
    ["Status is visible at every step",   "tasks.md shows exactly what's done, in progress, and remaining."],
    ["Scope changes are explicit decisions","Any new idea becomes a new spec. The current build is locked."],
    ["AI builds against an approved spec","Speed applies to the right direction. No guessing."],
    ["Problems caught at the gate",       "The spec review is 30 minutes. A rework cycle is 2 weeks."],
  ];

  function bafCol(x, accent, headerText, headerColor, items, isAfter) {
    s.addShape(pres.shapes.RECTANGLE,
      { x, y:2.35, w:5.95, h:4.7, fill:{color:CARD}, line:{color: isAfter ? TEAL : BORDER, width: isAfter ? 1.5 : 1}, shadow:mkShadow() });
    s.addShape(pres.shapes.RECTANGLE,
      { x, y:2.35, w:5.95, h:0.8, fill:{color:headerColor}, line:{type:"none"} });
    s.addText(headerText, { x:x+0.35, y:2.35, w:5.4, h:0.8,
      fontSize:15, bold:true, color:"FFFFFF", charSpacing:2.5, valign:"middle", fontFace:BFONT, margin:0 });
    let iy = 3.35;
    items.forEach((it) => {
      const icImg = isAfter ? ic.check : ic.warn;
      circle(s, icImg, isAfter ? "E6F8F7" : "FEF3DC", x+0.35, iy+0.02, 0.38);
      s.addText(it[0], { x:x+0.9, y:iy+0.02, w:4.85, h:0.36,
        fontSize:13.5, bold:true, color:INK, fontFace:BFONT, margin:0 });
      s.addText(it[1], { x:x+0.9, y:iy+0.4, w:4.85, h:0.34,
        fontSize:11, color:MUTED, fontFace:BFONT, margin:0 });
      iy += 0.86;
    });
  }
  bafCol(0.65, null, "WITHOUT SDD", "8A94A6", beforeItems, false);
  bafCol(6.7, null, "WITH SDD", TEAL, afterItems, true);
  footer(s, 10, false);

  // ══════════════════════════════════════════════════════════════
  // SLIDE 11 — BUSINESS VALUE
  // ══════════════════════════════════════════════════════════════
  s = pres.addSlide();
  s.background = { color: NAVY };
  kicker(s, "Why it pays off", TEAL);
  heading(s, "What this buys the business", "FFFFFF");
  sub(s, "Each benefit is a direct consequence of the process — not a side effect.", ICE);

  const vals = [
    ["Predictability",   TEAL,
     "Every feature follows the same path. Timelines are easier to estimate because the process is consistent. Surprises happen at the spec stage — not at the launch.",
     "Same process → same predictability → better planning."],
    ["Less rework",      TEAL,
     "Catching \"wrong thing\" at the 30-minute spec review costs almost nothing. Catching it after 2 weeks of build costs 2 weeks plus morale plus opportunity cost.",
     "The spec review is the cheapest QA step in the entire process."],
    ["Full traceability",TEAL,
     "Any line of code can be traced back to a task. Any task can be traced back to a spec. Any spec was approved by a named person. You always have an answer for \"why was this built?\"",
     "No more mystery features, no more forgotten context."],
    ["AI with guardrails",TEAL,
     "AI is now the most powerful accelerator in software development — but only when it's pointed in the right direction. SDD provides the approved spec that AI builds against, so speed doesn't become a liability.",
     "AI multiplies your velocity. SDD makes sure that velocity is directed."],
  ];
  vals.forEach((v, i) => {
    const x = 0.65 + (i % 2) * 6.2;
    const y = 2.4 + Math.floor(i / 2) * 2.4;
    s.addShape(pres.shapes.RECTANGLE,
      { x, y, w:5.9, h:2.25, fill:{color:NAVY3}, line:{color:"44608F", width:1.25}, shadow:mkShadow() });
    s.addShape(pres.shapes.RECTANGLE,
      { x, y, w:0.1, h:2.25, fill:{color:v[1]}, line:{type:"none"} });
    s.addText(v[0], { x:x+0.4, y:y+0.2, w:5.3, h:0.5,
      fontSize:22, bold:true, color:TEAL, fontFace:HFONT, margin:0 });
    s.addText(v[2], { x:x+0.4, y:y+0.72, w:5.35, h:0.9,
      fontSize:12, color:ICE, fontFace:BFONT, margin:0 });
    s.addShape(pres.shapes.LINE, { x:x+0.4, y:y+1.68, w:5.3, h:0, line:{color:"44608F", width:0.75} });
    s.addText(v[3], { x:x+0.4, y:y+1.74, w:5.35, h:0.42,
      fontSize:11, italic:true, color:AMBER, fontFace:BFONT, margin:0 });
  });
  footer(s, 11, true);

  // ══════════════════════════════════════════════════════════════
  // SLIDE 12 — THE ASK
  // ══════════════════════════════════════════════════════════════
  s = pres.addSlide();
  s.background = { color: NAVY };
  s.addShape(pres.shapes.OVAL,
    { x:11.4, y:-0.6, w:2.8, h:2.8, fill:{color:TEAL, transparency:85}, line:{type:"none"} });

  s.addText("THE ASK", { x:0.9, y:1.3, w:8, h:0.35,
    fontSize:12.5, bold:true, color:TEAL, charSpacing:4, fontFace:BFONT, margin:0 });
  s.addText("Let's pilot it on one feature", { x:0.85, y:1.72, w:12, h:1.05,
    fontSize:44, bold:true, color:"FFFFFF", fontFace:HFONT, margin:0 });
  s.addText(
    "Pick one real upcoming feature and run it end-to-end through SDD. " +
    "You'll see a spec written for you to read and approve, the approval gates in action, " +
    "and a full paper trail of what was agreed to and why — before a single line of code is written. " +
    "Low risk, real evidence.",
    { x:0.9, y:2.82, w:11.5, h:1.2, fontSize:15, color:ICE, fontFace:BFONT, margin:0 }
  );

  const asks = [
    [ic.flagW,  "Step 1: Choose a feature",
     "Pick one real upcoming feature from the current roadmap — small or medium scope is best for a first run."],
    [ic.userW,  "Step 2: Name the approver",
     "Identify who will approve the spec (what/why) and give the go before the build. Usually the PM or product owner."],
    [ic.eye,    "Step 3: Review the result",
     "After implement, we walk you through the full paper trail: spec → plan → tasks → shipped, all traceable."],
  ];
  asks.forEach((a, i) => {
    const x = 0.85 + i * 4.1;
    const y = 4.42;
    s.addShape(pres.shapes.RECTANGLE,
      { x, y, w:3.85, h:2.7, fill:{color:NAVY3}, line:{color:"44608F", width:1.25}, shadow:mkShadow() });
    circle(s, a[0], "2C4C82", x+0.35, y+0.3, 0.72);
    s.addText(a[1], { x:x+1.25, y:y+0.35, w:2.45, h:0.52,
      fontSize:15, bold:true, color:"FFFFFF", fontFace:HFONT, margin:0 });
    s.addText(a[2], { x:x+0.35, y:y+1.15, w:3.32, h:1.42,
      fontSize:12, color:ICE, fontFace:BFONT, margin:0 });
  });

  await pres.writeFile({ fileName: "SDD-for-Business-Owner.pptx" });
  console.log("WROTE SDD-for-Business-Owner.pptx");
})();
