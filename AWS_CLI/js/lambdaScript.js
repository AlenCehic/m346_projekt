// Autor: Matthias Hug, Alen Cehic
// Datum: 2023-12-14
// Version: 1.0
// Beschreibung: Lambda Sckript für das verkleinern von Bildern



'use strict';


const AWS = require('aws-sdk');
const sharp = require('sharp');

exports.handler = async (event, context) => {
    // Erstellt eine neue S3 Instanz
    const s3 = new AWS.S3();

    // Holt den Bucket Namen aus dem Event
    const bucket = event.Records[0].s3.bucket.name;

    // Holt den Key des Bildes aus dem Event
    const key = decodeURIComponent(event.Records[0].s3.object.key.replace(/\+/g, ' '));

    // Holt den Resize Wert aus der Umgebungsvariable
    let percentageResize = process.env.PERCENTAGE_RESIZE;

    try {
        // Holt das Bild aus dem Bucket
        const data = await s3.getObject({ Bucket: bucket, Key: key }).promise();
        const image = sharp(data.Body);

        // Bildgrösse anpassen
        const metadata = await image.metadata();
        let size = Math.round(metadata.width * percentageResize / 100);
        console.log(`Resizing ${key} to ${size}`);
        let resizedImage = await image.resize(size).toBuffer();

        // Ladet das BIld in den Bucket hoch
        await s3.putObject({
            Body: resizedImage,
            Bucket: s3.listObjects(process.env.BUCKET_NAME_COMPRESSED).params,
            Key: `resized-${key}`,
            ContentType: 'image/jpeg'
        }).promise();
    } catch (err) {
        console.error(err);
    }
}
