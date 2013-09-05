/**
 * Module dependencies
 */

var Model = require('modinha')
  , crypto = require('crypto')
  ;


/**
 * Model definition
 */

var Client = Model.extend(null, {
  schema: {
  	_id:         { type: 'any' },
    user_id:     { type: 'string', required: true },
  	type:        { type: 'string', required: true, enum: ['confidential', 'public'] },
  	name:        { type: 'string' },
  	website:     { type: 'string' },
  	description: { type: 'string' },
  	logo:        { type: 'string' },
  	terms:       { type: 'boolean' },
  	secret:      { type: 'string' },
  	created:     { type: 'any' },
  	modified:    { type: 'any' }
  }
});


/**
 * Client Registration
 */

Client.register = function (attrs, callback) {
	attrs.secret = crypto.randomBytes(10).toString('hex');
	Client.create(attrs, function (err, client) {
		if (err) { return callback(err); }
		callback(null, client);
	});
};


/**
 * Exports
 */

module.exports = Client;