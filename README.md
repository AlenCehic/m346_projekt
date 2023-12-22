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

### Ausführen des Setup.sh Scripts

*Durgeführt am 14.12.2023 von Matthias Hug*

In diesem Test testen wir die Funktionalität vom Script

Details zu diesem Test [>hier<](Dokumentation/Test%202023-12-14.md) 

## Reflexion
