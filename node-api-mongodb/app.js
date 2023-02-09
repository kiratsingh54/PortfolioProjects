const express = require('express')  // Express is a minimal and flexible Node.js 
const {ObjectId} = require('mongodb')
                                    // web application framework that provides a 
                                    // robust set of features for web and mobile applications.
const {connectToDb, getDb} = require('./db')
var mongo = require('mongodb');
// init app & middleware
const app = express()   //initializes the app
app.use(express.json())

// db connection
let db

connectToDb((err) => {
    if(!err) {
        app.listen(3000, () => {    // specifies that we can listen on local host port 3000
            console.log('app listening on port 3000')
        })
        db = getDb()
    }
})

// routes
app.get('/books', (req, res) => {   // route handler for get request
    // current page
    const page = req.query.p || 0   // if const p doesn't have value it should be 0
    const booksPerPage = 3
    
    let books = []

    db.collection('books')  // gets the book collection from the db
        .find() // cursor 'toArray', 'forEach'
        .sort({author: 1})
        .skip(page * booksPerPage)  // skip books depending of page requested
        .limit(booksPerPage)
        .forEach(book => books.push(book)) // asynchronous
        .then(() => {
            res.status(200).json(books)
        })
        .catch(() => {
            res.status(500).json({error: 'Could not fetch the documents'})
        })
})

app.get('/books/:id', (req, res) => { // to get all the books

    if (ObjectId.isValid(req.params.id)) {  // this makes sure that the length of id provided is correct
        var o_id = new mongo.ObjectId(req.params.id)
        db.collection('books')
            .findOne({'_id': o_id})
            .then(doc=> {
                res.status(200).json(doc)
            })
            .catch(err => {
                res.status(500).json({error: 'Could not fetch the document'})
            })
    }
    else {
        res.status(500).json({error: 'Not a valid doc id'})
    }
})

app.post('/books', (req, res) => { // adding a book and reviews
    const book = req.body

    db.collection('books')
        .insertOne(book)
        .then(result => {
            res.status(201).json(result)
        })
        .catch(err => {
            res.status(500).json({err: 'Could not create a new document'})
        })
})

app.delete('/books/:id', (req, res) =>{ // deleting book and its reviews

    if (ObjectId.isValid(req.params.id)) {  // this makes sure that the length of id provided is correct
        var o_id = new mongo.ObjectId(req.params.id)
        db.collection('books')
            .deleteOne({'_id': o_id})
            .then(result => {
                res.status(200).json(result)
            })
            .catch(err => {
                res.status(500).json({error: 'Could not delete the document'})
            })
    }
    else {
        res.status(500).json({error: 'Not a valid doc id'})
    }
})

app.patch('/books/:id', (req, res) => {
    const updates = req.body

    if (ObjectId.isValid(req.params.id)) {  // this makes sure that the length of id provided is correct
        var o_id = new mongo.ObjectId(req.params.id)
        db.collection('books')
            .updateOne({'_id': o_id}, {$set: updates} )
            .then(doc=> {
                res.status(200).json(doc)
            })
            .catch(err => {
                res.status(500).json({error: 'Could not update the document'})
            })
    }
    else {
        res.status(500).json({error: 'Not a valid doc id'})
    }

})