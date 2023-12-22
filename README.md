# M346_Projekt

## Benötigte Umgebung

Ubuntu 22.04

## Erste Schritte

1. .aws/credentials oder mit aws configure die credentials hinterlegen für die cli (die credentials findet man im learner Lab unter AWS Details)
2. Öffnen Sie die Kommandozeile
3. Vergewissern Sie sich, dass Sie sich im Ordner ./AWS_CLI vom git Repo befinden, falls nicht, wechseln Sie in diesen Ordner.
4. Fügen Sie den folgenden Befehl ein

```cmd
    ./setup.sh
```

Standartmässig wird das erste mal ein Setup durchgeführt. Mit diesem werden die Buckets erstellt und gewisse Systemumgebungsvariablen gesetzt, wenn diese Systemumgebungsvariablen bereits exestieren, kommt man in ein Menu in welchem man verscheidene aktionen durchführen kann, wie den Bucket ändern, die Prozentwerte ändern, usw.

> **Warnung:** Wenn man explizit ein setup machen will, darf man keine exestierende lambdafunktion mit dem namen "compressImage" haben!

## Gebrauchte Pakete in der Lambda Funktion

- aws-sdk
- sharp

## Tests

| Test | Durchgeführt am | Durchgeführt von | Beschreibung |
|------|-----------------|-------------------|--------------|
| Script.sh korrekte Ausführung und zeigt, was es soll | 14.12.2023 | Matthias Hug | In diesem Test wurde die erste Funktionalität des Scripts getestet. Details sind [hier](Dokumentation/Test%202023-12-14.md) verfügbar. |
| Script.sh wird getestet bis fast alle Funktionalitäten vorhanden sind, auch wird getestet, ob die Lambdafunktion korrekt ist und Buckets erstellt werden | 21.12.2023 | Matthias Hug & Cehic Alen | In diesem Test wurden Fehler in der Funktionalität des Scripts behoben. Details sind [hier](Dokumentation/Test%202023-12-21.md) verfügbar. |
| Letzte Anpassung in Script.sh | 22.12.2023 | Matthias Hug | In diesem Test wurden Feinschliffe durchgeführt und eine allgemeine Überprüfung vorgenommen. Details sind [hier](Dokumentation/Test%202023-12-22.md) verfügbar. |


## Reflexion

Die Reflexionen sind in seperaten files von [Matthias Hug](Dokumentation/Reflexion-MatthiasHug.md) und [Alen Cehic](Dokumentation/Reflexion-AlenCehic.md) 


## Aufgabenverteilung

Im allgemeinen haben wir beide ein bischen alles gemacht, jedoch habe wir uns je auf etwas anderes "konzentriert"

### Matthias Hug

Hauptaufgabe: Dokumentierung & Tests
Hilft bei Scripten

### Alen Cehic

Hauptaufgabe: Scripten
Holt rückmeldung bei Tests und hilft beim Dokumentieren