param(
    [string]$PresentationPath = (Join-Path $PSScriptRoot 'ROSI_Fallstudie_Praesentation.pptx'),
    [string]$TemplatePath = (Join-Path $PSScriptRoot '..\..\..\templates\Grenzebach_PowerPoint_Master_DE.potx')
)

$ErrorActionPreference = 'Stop'

$expectedTitles = @(
    'Analyse der Verfügbarkeit, Ausfalltoleranz und Konsistenz des KI-basierten Multisensorik-ROSI-Systems',
    'Ausgangslage und Forschungsfrage',
    'Systemarchitektur und Referenzbetrieb',
    'Untersuchungsdesign: fünf Fault-Injection-Cases',
    'C1 – Prozessausfälle und Laufzeit-Supervision',
    'C2 – Ressourcenerschöpfung im Bildarchiv',
    'C3 – Blockierende Log-Queue',
    'C4 – Veraltete Datenbankverbindungen',
    'C5 – Prüfung einer Shared-Memory-Race-Hypothese',
    'Synthetisierte Ursache-Wirkungs-Kette',
    'Handlungsempfehlungen für den Dauerbetrieb',
    'Evidenzgrenzen und Produktionstransfer',
    'Fazit und Diskussion'
)

$expectedLayouts = @(
    'Title',
    '1Picture_1Text',
    'Big object + 1 text box',
    '1Picture_1Text',
    '1Picture_1Text',
    'Big object + 2 text boxes',
    '1Picture_1Text',
    '1Picture_1Text',
    '1Picture_1Text',
    '1Picture_1Text',
    'Content | 4 text boxes',
    'Content | 4 text boxes',
    'Thank you'
)

$fadeEffect = 3849
$requiredSubtitle = 'Empirische Fault-Injection-Analyse auf Prozess- und Betriebssystemebene · Luca Michael Schmidt · September 2026'
$footerText = 'ROSI · Verfügbarkeit und Fehlertoleranz'
$imageAsset = 'case2_image_out_usage.png'
$imageSource = Join-Path $PSScriptRoot 'diagrams\case2_image_out_usage.png'

function Get-PlaceholderType([object]$Shape) {
    try { return [int]$Shape.PlaceholderFormat.Type } catch { return 0 }
}

function Get-Text([object]$Shape) {
    try { return [string]$Shape.TextFrame.TextRange.Text } catch { return '' }
}

function Get-SpeakerNotes([object]$Slide) {
    foreach ($shape in $Slide.NotesPage.Shapes) {
        try {
            if ($shape.PlaceholderFormat.Type -eq 2 -and $shape.HasTextFrame -eq -1 -and $shape.TextFrame.HasText -eq -1) {
                return $shape.TextFrame.TextRange.Text.Trim()
            }
        } catch {}
    }
    return ''
}

function Get-Rgb([object]$ColorFormat) {
    try { return [int]$ColorFormat.RGB } catch { return -1 }
}

function Test-TextOverflow([object]$Shape, [int]$SlideIndex, [System.Collections.Generic.List[string]]$Errors) {
    if ($Shape.HasTextFrame -ne -1 -or $Shape.TextFrame.HasText -ne -1) { return }
    try {
        $boundHeight = [double]$Shape.TextFrame2.TextRange.BoundHeight
        if ($boundHeight -gt ([double]$Shape.Height + 3)) {
            $Errors.Add("Folie ${SlideIndex}, Shape '$($Shape.Name)': Textüberlauf ($([Math]::Round($boundHeight, 1)) > $([Math]::Round($Shape.Height, 1))).")
        }
    } catch {}
}

function Test-HeaderFooter([object]$Slide, [System.Collections.Generic.List[string]]$Errors) {
    try {
        $headers = $Slide.HeadersFooters
        if ($headers.DateAndTime.Visible -ne -1) { $Errors.Add("Folie $($Slide.SlideIndex): natives Datum ist nicht sichtbar.") }
        if ($headers.Footer.Visible -ne -1) { $Errors.Add("Folie $($Slide.SlideIndex): nativer Footer ist nicht sichtbar.") }
        if ($headers.SlideNumber.Visible -ne -1) { $Errors.Add("Folie $($Slide.SlideIndex): native Seitenzahl ist nicht sichtbar.") }
        if ([string]::IsNullOrWhiteSpace([string]$headers.Footer.Text)) { $Errors.Add("Folie $($Slide.SlideIndex): nativer Footer besitzt keinen Text.") }
        if ([string]$headers.Footer.Text -ne $footerText) { $Errors.Add("Folie $($Slide.SlideIndex): Footertext ist nicht '$footerText'.") }
    } catch {
        $Errors.Add("Folie $($Slide.SlideIndex): native Kopf-/Fußzeilen konnten nicht geprüft werden: $($_.Exception.Message)")
    }
}

function Test-NoGreenOrEffects([object]$Shape, [int]$SlideIndex, [System.Collections.Generic.List[string]]$Errors) {
    try {
        if ($Shape.Shadow.Visible -eq -1) { $Errors.Add("Folie ${SlideIndex}: Shape '$($Shape.Name)' besitzt einen verbotenen Schlagschatten.") }
    } catch {}
    try {
        if ($Shape.Type -eq 1 -and [int]$Shape.AutoShapeType -eq 5) {
            $Errors.Add("Folie ${SlideIndex}: runde Rechteck-Shape '$($Shape.Name)' gefunden.")
        }
    } catch {}
    foreach ($color in @(
        (Get-Rgb $Shape.Fill.ForeColor),
        (Get-Rgb $Shape.Line.ForeColor),
        (Get-Rgb $Shape.TextFrame2.TextRange.Font.Fill.ForeColor)
    )) {
        $red = $color -band 0xFF
        $green = ($color -shr 8) -band 0xFF
        $blue = ($color -shr 16) -band 0xFF
        if ($color -eq 0x37908C -or $color -eq 0x8C9037 -or $color -eq 0x008000 -or $color -eq 0x00FF00 -or ($green -gt 115 -and $green -gt ($red * 1.15) -and $green -gt ($blue * 1.05))) {
            $Errors.Add("Folie ${SlideIndex}: verbotener Grünton 0x$('{0:X6}' -f $color) in Shape '$($Shape.Name)'.")
        }
    }
}

if (-not (Test-Path -LiteralPath $PresentationPath)) { throw "Präsentation fehlt: $PresentationPath" }
if (-not (Test-Path -LiteralPath $imageSource)) { throw "Konvertiertes Bildasset fehlt: $imageSource" }

$powerPoint = $null
$templatePresentation = $null
$presentation = $null
$errors = [System.Collections.Generic.List[string]]::new()
$speakerWords = 0
$speakerSeconds = 0
$fadeCount = 0
$pictureCount = 0
$contentShapeCount = 0
$tableCount = 0
$connectorCount = 0
$nativeShapeCount = 0
$pictureSlideIndexes = [System.Collections.Generic.List[int]]::new()

try {
    $powerPoint = New-Object -ComObject PowerPoint.Application
    $powerPoint.Visible = -1
    if (-not (Test-Path -LiteralPath $TemplatePath)) { $errors.Add("Firmentemplate fehlt: $TemplatePath") }
    if ($errors.Count -eq 0) {
        $templatePresentation = $powerPoint.Presentations.Open((Resolve-Path -LiteralPath $TemplatePath).Path, -1, 1, 0)
        $templateWidth = [double]$templatePresentation.PageSetup.SlideWidth
        $templateHeight = [double]$templatePresentation.PageSetup.SlideHeight
        $templatePresentation.Close()
        $templatePresentation = $null
    }
    $presentation = $powerPoint.Presentations.Open((Resolve-Path -LiteralPath $PresentationPath).Path, -1, 0, 0)

    if ($errors.Count -eq 0) {
        $presentationWidth = [double]$presentation.PageSetup.SlideWidth
        $presentationHeight = [double]$presentation.PageSetup.SlideHeight
        if ([Math]::Abs($presentationWidth - $templateWidth) -gt 0.01 -or [Math]::Abs($presentationHeight - $templateHeight) -gt 0.01) {
            $errors.Add("Foliendimension $([Math]::Round($presentationWidth, 3))x$([Math]::Round($presentationHeight, 3)) statt POTX-Größe $([Math]::Round($templateWidth, 3))x$([Math]::Round($templateHeight, 3)).")
        }
    }

    if ($presentation.Slides.Count -ne $expectedTitles.Count) {
        $errors.Add("Erwartet: $($expectedTitles.Count) Folien; gefunden: $($presentation.Slides.Count)")
    }

    $slideCount = [Math]::Min($presentation.Slides.Count, $expectedTitles.Count)
    for ($index = 1; $index -le $slideCount; $index++) {
        $slide = $presentation.Slides.Item($index)
        $layoutName = [string]$slide.CustomLayout.Name
        if ($layoutName -ne $expectedLayouts[$index - 1]) {
            $errors.Add("Folie ${index}: Layout '$layoutName' statt '$($expectedLayouts[$index - 1])'.")
        }

        if ($index -ge 2 -and $index -le 12) { Test-HeaderFooter -Slide $slide -Errors $errors }

        $titleShapes = @($slide.Shapes | Where-Object { (Get-PlaceholderType $_) -eq 1 })
        $bodyPlaceholders = @($slide.Shapes | Where-Object { (Get-PlaceholderType $_) -eq 2 } | Sort-Object Top, Left)
        if ($index -eq 1 -or $index -eq 13) {
            if ($bodyPlaceholders.Count -lt 2) { $errors.Add("Folie $index benötigt die zwei nativen Title-Layout-Textplatzhalter.") }
        } else {
            if ($titleShapes.Count -lt 1) { $errors.Add("Folie $index besitzt keinen nativen Titelplatzhalter.") }
            if ($bodyPlaceholders.Count -lt 2) { $errors.Add("Folie $index besitzt zu wenige native Textplatzhalter (Kicker/Quelle).") }
            $sourceText = ($bodyPlaceholders | ForEach-Object { Get-Text $_ }) -join ' '
            if ($sourceText -notmatch 'Quelle:') { $errors.Add("Folie $index besitzt keine ausgefüllte Quellenangabe im nativen Textplatzhalter.") }
            if ($index -ge 2 -and $index -le 10) {
                $mainBody = @($bodyPlaceholders | Where-Object { $_.Top -ge 90 -and $_.Top -lt 480 } | Where-Object { -not [string]::IsNullOrWhiteSpace((Get-Text $_)) })
                if ($mainBody.Count -eq 0) { $errors.Add("Folie $index besitzt keinen sinnvoll befüllten nativen Body-Placeholder.") }
            }
        }

        $title = if ($index -eq 1 -or $index -eq 13) { Get-Text $bodyPlaceholders[0] } else { Get-Text ($titleShapes | Select-Object -First 1) }
        if ($title.Trim() -ne $expectedTitles[$index - 1]) {
            $errors.Add("Folie ${index}: unerwarteter Titel '$($title.Trim())'.")
        }
        if ($index -eq 1 -and (Get-Text $bodyPlaceholders[1]).Trim() -ne $requiredSubtitle) {
            $errors.Add('Folie 1: verbindlicher Untertitel fehlt oder ist abweichend.')
        }
        if ($index -eq 1) {
            $subtitle = (Get-Text $bodyPlaceholders[1]).Trim()
            if ($subtitle -notmatch 'Luca Michael Schmidt') { $errors.Add('Folie 1: Autor Luca Michael Schmidt fehlt im nativen Untertitel.') }
            if ($subtitle -notmatch 'September 2026') { $errors.Add('Folie 1: September 2026 fehlt im nativen Untertitel.') }
        }

        $slidePictures = 0
        foreach ($shape in @($slide.Shapes)) {
            $type = [int]$shape.Type
            if ($type -eq 13 -or $type -eq 11 -or $type -eq 28) {
                $slidePictures++
                $pictureCount++
                $pictureSlideIndexes.Add($index)
                if ($index -ne 6) { $errors.Add("Folie ${index}: Bildasset '$($shape.Name)' gefunden; nur Folie 6 darf das eine Bildasset enthalten.") }
                if ($index -eq 6) {
                    $alternativeText = [string]$shape.AlternativeText
                    if ($alternativeText -notmatch [regex]::Escape($imageAsset)) { $errors.Add("Folie 6: Bild besitzt keinen erwarteten Assetverweis '$imageAsset'.") }
                    try {
                        Add-Type -AssemblyName System.Drawing
                        $image = [System.Drawing.Image]::FromFile((Resolve-Path -LiteralPath $imageSource).Path)
                        $assetRatio = [double]$image.Width / [double]$image.Height
                        $shapeRatio = [double]$shape.Width / [double]$shape.Height
                        if ([Math]::Abs($assetRatio - $shapeRatio) -gt 0.02) {
                            $errors.Add("Folie 6: Bildseitenverhältnis verändert (Asset $([Math]::Round($assetRatio, 4)) vs. Shape $([Math]::Round($shapeRatio, 4))).")
                        }
                        $image.Dispose()
                    } catch { $errors.Add("Folie 6: Bildseitenverhältnis konnte nicht geprüft werden: $($_.Exception.Message)") }
                }
            }
            if ($type -eq 19) { $tableCount++; $contentShapeCount++ }
            try {
                if ($type -eq 9 -or $shape.Connector -eq -1) { $connectorCount++; $contentShapeCount++ }
            } catch {
                if ($type -eq 9) { $connectorCount++; $contentShapeCount++ }
            }
            if ($type -eq 1 -or $type -eq 17) { $nativeShapeCount++; $contentShapeCount++ }
            Test-NoGreenOrEffects -Shape $shape -SlideIndex $index -Errors $errors
            Test-TextOverflow -Shape $shape -SlideIndex $index -Errors $errors
            if ($type -eq 19) {
                try {
                    for ($row = 1; $row -le $shape.Table.Rows.Count; $row++) {
                        for ($column = 1; $column -le $shape.Table.Columns.Count; $column++) {
                            $cellShape = $shape.Table.Cell($row, $column).Shape
                            $fillColor = Get-Rgb $cellShape.Fill.ForeColor
                            $red = $fillColor -band 0xFF
                            $green = ($fillColor -shr 8) -band 0xFF
                            $blue = ($fillColor -shr 16) -band 0xFF
                            if ($green -gt 115 -and $green -gt ($red * 1.15) -and $green -gt ($blue * 1.05)) {
                                $errors.Add("Folie ${index}: verbotener Grünton in Tabellenzelle $row/$column.")
                            }
                        }
                    }
                } catch { $errors.Add("Folie ${index}: Tabellenfarben konnten nicht geprüft werden.") }
            }
            $text = Get-Text $shape
            if ($text -match 'Klicken, um|Präsentationstitel|Unterüberschrift|THEMA [0-9]+|Bild einfügen') {
                $errors.Add("Folie $index enthält unveränderten Template-Platzhaltertext in '$($shape.Name)'.")
            }
            if ($text -match 'Sperrvermerk') {
                $errors.Add("Folie $index zeigt den Sperrvermerk sichtbar in '$($shape.Name)'.")
            }
        }

        if ($index -ge 2 -and $index -le 12 -and $contentShapeCount -eq 0) {
            $errors.Add("Folie ${index}: keine nativen Visual-Objekte gefunden.")
        }

        if ($slide.SlideShowTransition.EntryEffect -ne $fadeEffect) {
            $errors.Add("Folie ${index}: kein Fade-Übergang (EntryEffect=$($slide.SlideShowTransition.EntryEffect)).")
        } else { $fadeCount++ }
        try {
            if ([Math]::Abs([double]$slide.SlideShowTransition.Duration - 0.4) -gt 0.15) {
                $errors.Add("Folie ${index}: Fade-Dauer ist nicht 0,4 s ($($slide.SlideShowTransition.Duration)).")
            }
        } catch { $errors.Add("Folie ${index}: Fade-Dauer konnte nicht geprüft werden.") }

        $notes = Get-SpeakerNotes $slide
        if ($notes -notmatch '^Sprechzeit:\s*\d+:\d{2}') {
            $errors.Add("Folie $index besitzt keine Sprecher-Notiz mit Zeitangabe.")
        } else {
            $timeMatch = [regex]::Match($notes, '^Sprechzeit:\s*(\d+):(\d{2})')
            $speakerSeconds += ([int]$timeMatch.Groups[1].Value * 60) + [int]$timeMatch.Groups[2].Value
        }
        if ($notes -notmatch 'Quellenhinweis:') { $errors.Add("Folie $index besitzt keinen Quellenhinweis in den Sprecher-Notizen.") }
        $noteLines = @($notes -split "`r?`n" | Where-Object { $_.Trim() })
        $bulletLines = @($noteLines | Where-Object { $_ -notmatch '^Sprechzeit:' -and $_ -notmatch '^Quellenhinweis:' })
        if ($bulletLines.Count -lt 2 -or $bulletLines.Count -gt 5) {
            $errors.Add("Folie ${index}: $($bulletLines.Count) Sprechpunkte; erwartet 2–5 kurze Stichpunkte.")
        }
        foreach ($line in $bulletLines) {
            if ($line -notmatch '^[-–•]\s+') {
                $errors.Add("Folie ${index}: Sprecherhinweis ist kein Stichpunkt: '$line'.")
            }
            if (@($line -split '\s+' | Where-Object { $_ }).Count -gt 16) {
                $errors.Add("Folie ${index}: Sprecherstichpunkt ist länger als 16 Wörter: '$line'.")
            }
        }
        $speakerWords += @($notes -split '\s+' | Where-Object { $_ }).Count
    }

    if ($pictureCount -ne 1) { $errors.Add("Eingebettete Bilder: $pictureCount; erwartet genau 1 Bildasset auf Folie 6.") }
    if (@($pictureSlideIndexes | Sort-Object -Unique) -join ',' -ne '6') { $errors.Add("Bildasset liegt auf unerwarteten Folien: $(@($pictureSlideIndexes | Sort-Object -Unique) -join ',').") }
    if ($tableCount -lt 1) { $errors.Add('Mindestens eine native PowerPoint-Tabelle wird erwartet.') }
    if ($connectorCount -lt 3) { $errors.Add("Native Connectoren: $connectorCount; erwartet mindestens 3.") }
    if ($nativeShapeCount -lt 20) { $errors.Add("Native Shapes/Textfelder: $nativeShapeCount; erwartet mindestens 20.") }
    if ($fadeCount -ne $expectedTitles.Count) { $errors.Add("Fade-Übergänge: $fadeCount von $($expectedTitles.Count).") }
    if ($speakerSeconds -lt 720 -or $speakerSeconds -gt 840) { $errors.Add("Sprechzeit-Marker ergeben $speakerSeconds Sekunden; Zielbereich 12–14 Minuten.") }
    if ($speakerWords -lt 250 -or $speakerWords -gt 750) { $errors.Add("Sprechertext umfasst $speakerWords Wörter; Zielbereich 250–750 für kurze Stichpunkte.") }
} finally {
    if ($templatePresentation) { $templatePresentation.Close() }
    if ($presentation) { $presentation.Close() }
    if ($powerPoint) { $powerPoint.Quit() }
    if ($presentation) { [void][Runtime.InteropServices.Marshal]::ReleaseComObject($presentation) }
    if ($templatePresentation) { [void][Runtime.InteropServices.Marshal]::ReleaseComObject($templatePresentation) }
    if ($powerPoint) { [void][Runtime.InteropServices.Marshal]::ReleaseComObject($powerPoint) }
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}

if ($errors.Count -gt 0) { throw ($errors -join [Environment]::NewLine) }

[pscustomobject]@{
    Presentation = $PresentationPath
    Slides = $expectedTitles.Count
    SpeakerNoteWords = $speakerWords
    EstimatedMinutesFromMarkers = [Math]::Round($speakerSeconds / 60, 1)
    EmbeddedImages = $pictureCount
    NativeTables = $tableCount
    NativeConnectors = $connectorCount
    NativeShapesAndText = $nativeShapeCount
    SlideWidth = [Math]::Round($presentationWidth, 3)
    SlideHeight = [Math]::Round($presentationHeight, 3)
    TemplateWidth = [Math]::Round($templateWidth, 3)
    TemplateHeight = [Math]::Round($templateHeight, 3)
    FadeTransitions = $fadeCount
    Status = 'PASS'
} | ConvertTo-Json
