const path = require("path");
require("dotenv").config({ path: path.join(__dirname, "../.env") });
const cloudinary = require("cloudinary").v2;

function checkConfigured() {
  return Boolean(
    process.env.CLOUDINARY_CLOUD_NAME &&
    process.env.CLOUDINARY_API_KEY &&
    process.env.CLOUDINARY_API_SECRET
  );
}

function configureCloudinary() {
  if (checkConfigured()) {
    cloudinary.config({
      cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
      api_key: process.env.CLOUDINARY_API_KEY,
      api_secret: process.env.CLOUDINARY_API_SECRET,
    });
    return true;
  }
  return false;
}

// Initial configuration
configureCloudinary();

/**
 * Uploads a local file to Cloudinary and returns the secure HTTPS URL.
 * Returns null if Cloudinary is not configured.
 */
const uploadToCloudinary = async (filePath, folder = "jansamasya/reports") => {
  if (!configureCloudinary()) {
    return null;
  }
  const result = await cloudinary.uploader.upload(filePath, {
    folder,
    resource_type: "image",
  });
  return result.secure_url;
};

module.exports = {
  cloudinary,
  get isCloudinaryConfigured() {
    return checkConfigured();
  },
  uploadToCloudinary,
};
