### Step 1: Prepare the Web Application Code

#### Frontend Code (`index.html`)
Create a directory for your web application and inside it, create a `public` directory. In the `public` directory, create an `index.html` file with the following content:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Web Application</title>
</head>
<body>
    <h1>Welcome to the Web Application</h1>
    <form action="/upload" method="post" enctype="multipart/form-data">
        <input type="file" name="file" />
        <button type="submit">Upload</button>
    </form>
</body>
</html>
```

#### Backend Code (`server.js`)
In the root directory of your project, create a `server.js` file with the following content:

```javascript
const express = require('express');
const multer = require('multer');
const AWS = require('aws-sdk');
const fs = require('fs');
const path = require('path');

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
```

#### Dockerfile
In the root directory, create a `Dockerfile` with the following content:

```dockerfile
FROM node:14

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["node", "server.js"]
```

#### Package.json
In the root directory, create a `package.json` file with the following content:

```json
{
  "name": "web-app",
  "version": "1.0.0",
  "description": "A simple web application",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "aws-sdk": "^2.877.0",
    "express": "^4.17.1",
    "multer": "^1.4.2"
  }
}
```

#### Testing Locally
1. Install dependencies and create S3 bucket in AWS:
    ```sh
    npm install
    ```
![image](https://github.com/rk630/ProdiusLabs/assets/139606316/558fca63-888f-4531-ba62-ada65b430100)

2. Set environment variables (create a `.env` file with the following content):
    ```
    AWS_ACCESS_KEY_ID=<your-access-key-id>
    AWS_SECRET_ACCESS_KEY=<your-secret-access-key>
    S3_BUCKET_NAME=<your-s3-bucket-name>
    AWS_REGION=<your-aws-region>
    ```

3. Start the application:
    ```sh
    node server.js
    ```

4. Open your browser and navigate to `http://localhost:3000`. You should see the web application.

### Step 2: Build and Push Docker Image

1. Build the Docker image:
    ```sh
    docker build -t web-app .
    ```

2. Tag the Docker image:
    ```sh
    docker tag web-app:latest <your-dockerhub-username>/web-app:latest
    ```

3. Push the Docker image to Docker Hub:
![image](https://github.com/rk630/ProdiusLabs/assets/139606316/24c09318-13de-4a8a-86a2-1de2d0972030)

    ```sh
    docker push <your-dockerhub-username>/web-app:latest
    ```

![image](https://github.com/rk630/ProdiusLabs/assets/139606316/94c795b0-50d2-4099-b701-3fd44f825901)
![image](https://github.com/rk630/ProdiusLabs/assets/139606316/8b658572-8140-41b8-bdc2-fbb2841e3999)
