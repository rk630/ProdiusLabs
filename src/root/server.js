const express = require('express');
const multer = require('multer');
const AWS = require('aws-sdk');
const fs = require('fs');

const app = express();
const port = 3000;

const upload = multer({ dest: 'uploads/' });

const s3 = new AWS.S3({
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
    region: process.env.AWS_REGION
});

app.use(express.static('public'));

app.post('/upload', upload.single('file'), (req, res) => {
    const fileContent = fs.readFileSync(req.file.path);

    const params = {
        Bucket: process.env.S3_BUCKET_NAME,
        Key: req.file.originalname,
        Body: fileContent
    };

    s3.upload(params, (err, data) => {
        if (err) {
            return res.status(500).send("Error uploading file");
        }
        res.send(`File uploaded successfully. ${data.Location}`);
    });
});

app.listen(port, () => {
    console.log(`App running at http://localhost:${port}`);
});
