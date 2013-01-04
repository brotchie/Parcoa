#!/bin/sh

mkdir -p docs
appledoc -h --verbose 4 --keep-intermediate-files --keep-undocumented-members --project-name Parcoa --project-company "Factorial Products" --company-id com.factorialproducts --output docs Parcoa 
