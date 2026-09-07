extends Resource
class_name player_state
# This is a collection of local observable and non observable values
# when a certain scene its instantiated it can create its own state which it can share with any interface
# GAME ---- updates ----> STATE ---- signals ----- UI

# this is nice as it allows the state to be shared with multiple interfaces and avoids autoloads for variables and signal buses
