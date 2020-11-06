const sodium = require('tweetsodium')
const value = "plain-text-secret"
const key = "OvpKIvDS+cccMJmLxDk49g5KDGyYaXy9zndDK1zzzWY=";
const keyBytes = Buffer.from(key, 'base64');
const messageBytes = Buffer.from(value);
const encryptedBytes = sodium.seal(messageBytes, keyBytes);
const encrypted = Buffer.from(encryptedBytes).toString('base64')
console.log(encrypted);
