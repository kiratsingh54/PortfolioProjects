const {MongoClient} = require('mongodb')    // from mongodb dependency we are getting mongoClient

let dbConnection

module.exports = {
    connectToDb: (cb) => {    // asynchronous task
        MongoClient.connect('mongodb://127.0.0.1:27017/bookstore')  // connecting to local database
            .then((client) => { // after the connection has been made
                dbConnection = client.db()
                return cb()
            })
            .catch(err => {
                console.log(err)    // logging err if any during connection
                return cb(err)
            })
    },
    getDb: () => dbConnection
}