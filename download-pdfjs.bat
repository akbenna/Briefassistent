<!DOCTYPE html>
<html lang="nl">
<head>
<meta charset="UTF-8">
<title>Huisarts Brief Assistent</title>
<link rel="stylesheet" href="popup.css">
</head>
<body>
<div class="shell">

  <header>
    <div class="logo">
      <span class="cross">✚</span>
      <div>
        <h1>Brief<strong>Assistent</strong></h1>
        <p>Bricks · AVG-conform · v4</p>
      </div>
    </div>
    <div class="header-right">
      <span id="statusBadge" class="badge">verbinden...</span>
      <button class="avg-btn" onclick="chrome.tabs.create({url: chrome.runtime.getURL('avg-verantwoording.html')})">⚖ AVG</button>
    </div>
  </header>

  <!-- Niet op Bricks waarschuwing -->
  <div id="notBricks" class="alert warn" style="display:none">
    ⚠ Geen Bricks-pagina open. Dossier ophalen werkt alleen vanuit Bricks.
    U kunt wel een Screenshot of PDF invoeren.
  </div>

  <!-- ═══ STAP 1: DOSSIER ═══ -->
  <div class="step-label"><span class="stepnum">01</span> DOSSIER INVOEREN</div>

  <!-- Methode tabs -->
  <div class="method-tabs">
    <button class="mtab active" id="tab-bricks" onclick="switchTab('bricks')">🏥 Bricks</button>
    <button class="mtab" id="tab-screenshot" onclick="switchTab('screenshot')">🖥 Screenshot</button>
    <button class="mtab" id="tab-pdf-dossier" onclick="switchTab('pdf-dossier')">📄 PDF</button>
  </div>

  <!-- TAB: Bricks ophalen -->
  <div id="pane-bricks" class="tab-pane active">
    <div class="scrape-card" id="scrapeCard">
      <div id="scrapeIdle">
        <p class="card-icon">📋</p>
        <p class="card-title">Dossier ophalen uit Bricks</p>
        <p class="card-sub">Open het patiëntdossier in Bricks.<br>Klik door de tabs: Journaal · Medicatie · VG · Lab<br>Dan op de knop hieronder.</p>
      </div>
      <div id="scrapeDone" style="display:none">
        <p class="card-icon">✅</p>
        <p class="card-title green" id="scrapeTitle">Dossier opgehaald</p>
        <p class="card-sub" id="scrapeMeta"></p>
      </div>
    </div>
    <div class="row-btns">
      <button class="btn primary" id="scrapeBtn" onclick="scrapeDossier()">↓ Ophalen uit Bricks</button>
      <button class="btn ghost" id="clearScrapeBtn" style="display:none" onclick="clearDossier()">Wis</button>
    </div>
    <div id="scrapeDebug" class="debug-box" style="display:none"></div>
  </div>

  <!-- TAB: Screenshot -->
  <div id="pane-screenshot" class="tab-pane" style="display:none">
    <div class="screenshot-area" id="screenshotArea">
      <p class="card-icon">🖥️</p>
      <p class="card-title">Screenshot plakken</p>
      <p class="card-sub">
        1. Maak screenshot van Bricks scherm<br>
        &nbsp;&nbsp;&nbsp;(PrintScreen of Knipprogramma)<br>
        2. Klik in dit vak<br>
        3. Druk <strong>Ctrl+V</strong>
      </p>
      <div id="screenshotPreview"></div>
    </div>
    <div class="row-btns" style="margin-top:6px">
      <button class="btn primary" id="analyseScreenshotBtn" onclick="analyseScreenshot()" style="display:none">
        🔍 Analyseer screenshot
      </button>
      <button class="btn ghost" id="clearScreenshotBtn" onclick="clearScreenshot()" style="display:none">Wis</button>
    </div>
    <div id="screenshotStatus" class="card-sub" style="margin-top:5px;text-align:center"></div>
  </div>

  <!-- TAB: PDF dossier -->
  <div id="pane-pdf-dossier" class="tab-pane" style="display:none">
    <div class="drop-zone" id="dropDossier"
         onclick="document.getElementById('fileDossier').click()"
         ondragover="event.preventDefault();this.classList.add('over')"
         ondragleave="this.classList.remove('over')"
         ondrop="dzDropDossier(event)">
      <input type="file" id="fileDossier" accept=".pdf" style="display:none" onchange="loadDossierPDF(event)">
      <span id="dropDossierLabel">📄 Sleep Medicom/Bricks PDF export hier<br><small>of klik om te bladeren</small></span>
    </div>
    <div id="dossierPill" class="file-pill" style="display:none">
      <span id="dossierPillText"></span><button onclick="clearDossierPDF()">✕</button>
    </div>
  </div>

  <!-- Transparantie paneel -->
  <div id="transparantiePaneel" style="display:none">
    <div class="tp-header">
      <span>🛡 U bepaalt wat naar de AI gaat</span>
      <button class="preview-toggle" id="previewToggleBtn" onclick="togglePreview()">👁 Toon preview</button>
    </div>
    <div class="tp-naam" id="tpNaam"></div>
    <div id="sectieToggles"></div>
    <div id="previewContent" style="display:none">
      <pre id="previewText" class="preview-text"></pre>
    </div>
  </div>

  <div class="divider"></div>

  <!-- ═══ STAP 2: VRAAG-PDF ═══ -->
  <div class="step-label"><span class="stepnum">02</span> VRAAG-PDF AANVRAGER <span class="optioneel">optioneel</span></div>
  <div class="drop-zone" id="dropVraag"
       onclick="document.getElementById('fileVraag').click()"
       ondragover="event.preventDefault();this.classList.add('over')"
       ondragleave="this.classList.remove('over')"
       ondrop="dzDropVraag(event)">
    <input type="file" id="fileVraag" accept=".pdf" style="display:none" onchange="loadVraagPDF(event)">
    <span id="dropVraagLabel">📩 Sleep vraag-PDF hier<br><small>Advocaat / SMA / Gemeente / UWV — of klik</small></span>
  </div>
  <div class="file-pill" id="vraagPill" style="display:none">
    <span id="vraagPillText"></span><button onclick="clearVraag()">✕</button>
  </div>

  <div class="divider"></div>

  <!-- ═══ STAP 3: BRIEFTYPE ═══ -->
  <div class="step-label"><span class="stepnum">03</span> BRIEFTYPE</div>
  <div class="type-grid">
    <div class="type-btn active" data-type="advocaat" onclick="selectType(this)">⚖️ Advocaat</div>
    <div class="type-btn" data-type="sma" onclick="selectType(this)">🏥 SMA</div>
    <div class="type-btn" data-type="gemeente" onclick="selectType(this)">🏛️ Gemeente</div>
    <div class="type-btn" data-type="verzekeraar" onclick="selectType(this)">📋 Verzekeraar</div>
    <div class="type-btn" data-type="uwv" onclick="selectType(this)">💼 UWV</div>
    <div class="type-btn" data-type="overig" onclick="selectType(this)">✉️ Overig</div>
  </div>

  <!-- ═══ STAP 4: INSTRUCTIE ═══ -->
  <div class="step-label" style="margin-top:10px"><span class="stepnum">04</span> EXTRA INSTRUCTIE</div>
  <textarea id="extraInstructie" placeholder="Bijv: focus op 2022-2024 · beantwoord vraag 2 en 3 · benadruk prognose..."></textarea>

  <!-- API Sleutel -->
  <div id="apiSection" style="margin-top:10px">
    <div class="step-label">API SLEUTEL (eenmalig)</div>
    <div class="row-btns">
      <input type="password" id="apiKey" class="api-input" placeholder="sk-ant-api03-..." autocomplete="off"/>
      <button class="btn primary small" onclick="saveKey()">Sla op</button>
    </div>
    <p class="hint">Opgeslagen lokaal in Edge. Nooit verstuurd naar derden.</p>
  </div>
  <div class="key-ok" id="keyOk" style="display:none">
    🔑 API sleutel ingesteld · <button onclick="resetKey()">Wijzig</button>
  </div>

  <!-- Foutmelding -->
  <div class="alert error" id="errorBar" style="display:none"></div>

  <!-- Genereer -->
  <button class="btn gen" id="genBtn" onclick="generate()">✦ Genereer informatiebrief</button>

  <!-- Output -->
  <div id="outputWrap" style="display:none">
    <div class="output-header">
      <span>✓ Brief gegenereerd</span>
      <div>
        <button onclick="copyOutput()">Kopieer</button>
        <button onclick="clearAll()">Nieuw</button>
      </div>
    </div>
    <div class="output-body" id="outputBody"></div>
  </div>

</div>
<script src="pdfjs/pdf.min.js"></script>
<script src="popup.js"></script>
</body>
</html>
