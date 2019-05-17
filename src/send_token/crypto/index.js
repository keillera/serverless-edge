'use strict';

exports.handler = (event, context, callback) => {
  var request = event.Records[0].cf.request;
  if (request.method === 'POST') {
    request.body.action = 'replace';
    request.body.data = getUpdatedBody(request);
  }
  callback(null, request);
};

function getUpdatedBody(request) {
  /* HTTP body is always passed as base64-encoded string. Decode it. */
  const body = Buffer.from(request.body.data, 'base64').toString();
  const json_body = JSON.parse(body)
  json_body.text = json_body.text + 'aaaa'
  const b = new Buffer(JSON.stringify(json_body), 'ascii');
  return b.toString('base64')
}
