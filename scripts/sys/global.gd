extends Node2D

signal score_updated(new_score)  # Signal to notify subscribers when score updates

var score: int = 0

# Function to add score and emit signal
func add_score(amount: int):
	score += amount
	score_updated.emit(score)  # Emit the new score to update UI
