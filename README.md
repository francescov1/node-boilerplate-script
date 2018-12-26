# Node.js boilerplate generator

This script generates the necessary structure for a scalable Express.js, Node.js server.
The script performs the following operations:
- initialize npm
- create folders and files
- download commonly used packages
- write boilerplate code to files

After the script is ran, you will have a Node.js application that can be run without any additional configuration.
Certain features could be considered optional but are additions that I add to all my projects (such as Bluebird for promises). An example route and Mongoose model are also included to provide a simple template for getting started.

The directory structure generated is shown below:

.
├── config
│   ├── main.js       
├── controllers                    
│   ├── examples.js     
├── errors                    
│   ├── custom.js   
│   ├── middleware.js     
├── models                    
│   ├── user.js   
├── routes                    
│   ├── examples.js      
├── index.js
├── router.js   
├── .gitignore   
├── .env    
├── package.json
└── package-lock.json            
