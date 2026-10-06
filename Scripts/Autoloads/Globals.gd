extends Node
## This is a Global State Script
##
## Rules for adding variables here
## - Variables should be needed through multiple tscenes/interfaces
## - i.e Settings, Persistent player and world data, global constants
## - variables that get modified in a predictable manner i.e gold might be spent only in shops, but shown in multiple UIs
##
## Rules for adding functions here:
## - Functions that alter global state in a specific way, better if used in multiples scripts
## - Functions that compute data based on global state, only if small and used in multiple scripts
##
## Remember you can hide variables like so
## var _myvar : int = 5
##
## And make them constant with:
## const  MYCONSTANT : int = 5
