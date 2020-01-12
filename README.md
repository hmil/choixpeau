
Placez le choixpeau sur votre tête et il vous attribuera à une maison !

Hardware:
- nodemcu
- module ampli audio
- speaker
- 1 servo
- attiny13a
- Battery pack 3.6V
- Booster 3.6V -> 5V
- Détecteur de proxymité type capteur à réféction IR
- Plein de condensateurs chimiques sur le 5v car le nodemcu massacre la tension d'alim

Notes:
- Le capteur IR ne fonctionne pas pareil selon le type de chevelure
- L'attiny est flashé avec le firmware "pwm-expander" pour offrir des PWM pour contrôler des servos. (le nodemcu ne peut pas sortir de PWM en même temps que de l'audio)

Bonne chance pour trouver comment tout connecter ensemble.
