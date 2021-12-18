#!/bin/bash
cd ./lambda/
pip install --target ./package -r requirements.txt
cd package
zip -r ../app.zip .
cd ../
zip -g app.zip *.py
mv app.zip ../
rm -rf package
cd ../..