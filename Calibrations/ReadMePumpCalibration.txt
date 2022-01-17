The following is a summary of the steps to do a pump calibration as well as how to calculate drop sizes for your running experiment.

A. REWARD SYSTEM CALIBRATION
1. Load the reward container with water, (400ml to keep measures constant, height of the container should be irrelevant, 
   tip should go to a measuring container, voltage box should be at 6.5V).
2. Open the code "reward_pump_calibration" currently under \Dropbox\DAG\Reward_pump_calibrations.
3. Run the code according to the following:
	test_calibration(hits, open_time, close_time) where: 
	"hits" is the number of trials the pump will open and close (usually 500)
	"open_time" is the time in seconds for each valve opening test (for previous calibrations from 0.005s to 0.1 in 0.005s steps).
	"close_time" is the time in seconds between each opening (for previous calibrations 0.5s).
4. Report your measurement in the excel spreadsheet "Calibration" and document all the parameters you used to perform the calibration.
5. Repeat the measurement 1 to 2 times (depending on how stable the second measure was compared to the first one), always recording your measurements in the excell spreadsheet.
6. Get the water amount per hit (total ml measured / 500(for this example)) .


B. VISUALIZATION OF YOUR MEASUREMENTS (optional):
1. Open the function "ms2ml" currently under \Dropbox\DAG\Reward_pump_calibrations.

TO RUN "ms2ml" OR "s_per_ml" NOW YOU MUST KEEP YOUR CALIBRATION IN DIFFERENT SHEETS IN THE EXCEL FILE "Calibration" 
AND NAME THE SPECIFIC SHEET AS THE DATE OF YOUR CALIBRATION,
YOU DO NOT NEED TO INPUT ANY VALUE MANUALLY. 
JUST KEEP THE FORMAT AS THE ONE IN THE FIRST SHEET, DO NOT CHANGE ROW OR COLUMN SIZE OR POSITIONS.

2. Run the code according to the following:
	ml = ms2ml(ms, date, setup, toplot, ml2ms)
	"date" in the format 20131220, from the sheet with this calibration the program will calculate the desired values 
	"ms" is the amount of time you wanna test in milliseconds to see how much water the monkey will get per hit
	"setup" will be important once we have calibrations from different setups, (2) is the only valid input for now
	"toplot" should be (1) in order to see your data plotted with a reference line or (0) if you do not want to plot
	"ml2ms" should only be active (1) if you want to calculate ml2ms (the opposite), if not it should be (0)
	

C. GETTING THE OPENING TIME FOR YOUR EXPERIMENT
1. Open the function "s_per_ml" currently under \Dropbox\DAG\Reward_pump_calibrations.

TO RUN "ms2ml" OR "s_per_ml" NOW YOU MUST KEEP YOUR CALIBRATION IN DIFFERENT SHEETS IN THE EXCEL FILE "Calibration" 
AND NAME THE SPECIFIC SHEET AS THE DATE OF YOUR CALIBRATION,
YOU DO NOT NEED TO INPUT ANY VALUE MANUALLY. 
JUST KEEP THE FORMAT AS THE ONE IN THE FIRST SHEET, DO NOT CHANGE ROW OR COLUMN SIZE OR POSITIONS.

2. Run the code according to the following:
	s_per_ml(ml,date, n_trials,setup)
	"ml" is the total amount of water in milliliters you want to give to your monkey in one session 
	"date" in the format 20131220, from the sheet with this calibration the program will calculate the desired values 
	"n_trials" is the number of trials the monkey will need to succeed in order to get the ml specified
	"setup" will be important once we have calibrations from different ones, now only (2) is active, you do not need to input it
3. Input the result in your reward time in get_monkey_something and run you task.


That's it.
AUDV 20130410
