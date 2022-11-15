const express = require('express');
const app= express();

const port =8000;
app.get("/" , (req,res)=>{
    res.send("home page");
})

app.get("/about" , (req,res)=>{
    res.send("about page");
})

app.get("*" , (req,res)=>{
    res.send("404 errror");
})

app.listen(port, ()=>{
    console.log(" listening to port")
})