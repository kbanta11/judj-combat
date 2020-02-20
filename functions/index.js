const functions = require('firebase-functions');
const _ = require('lodash');

const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

const db = admin.firestore();

exports.updateScores = functions.firestore.document('/scores/{scoreId}').onWrite(async (change, context) => {
	let scoreData = change.after.data();
	let scoreId = context.params.scoreId;
	let fightId = scoreData['fight_id'];
	let userId = scoreData['user_id'];
	let redScores = scoreData['red_scores'];
	let blueScores = scoreData['blue_scores'];
	
	await db.collection('fights').doc(fightId.toString()).get().then(snapshot => {
		if(!snapshot.exists) {
			console.log('No Fight Doc Found');
		}
		console.log('Fight Doc: ' + snapshot.id);

		fightRedScores = snapshot.data().red_scores;
		fightBlueScores = snapshot.data().blue_scores;
		console.log('Red Scores ' + fightRedScores + '/Blue Scores ' + fightBlueScores);
		if(typeof fightRedScores === 'undefined' || typeof fightBlueScores === 'undefined') {
			fightRedScores = {};
			fightBlueScores = {};
			for(var rs in redScores) {
				console.log('Logging Red Score: ' + redScores[rs] + ' for Rd. ' + rs + ' for user ' + userId);
				let userScore = {};
				userScore[userId] = redScores[rs];
				fightRedScores[rs] = userScore;
			}
			for (var bs in blueScores) {
				console.log('Logging Blue Score: ' + blueScores[bs] + ' for Rd. ' + bs + ' for user ' + userId);
				let userScore = {};
				userScore[userId] = blueScores[bs];
				fightBlueScores[bs] = userScore;
			}
		} else {
			for(var rd_red in redScores) {
				let fight_rdr_scores = fightRedScores[rd_red];
				console.log('rd score type ' + typeof fight_rdr_scores);
				if(typeof fight_rdr_scores === 'undefined'){
					fightRedScores[rd_red] = {};
					fightRedScores[rd_red][userId] = redScores[rd_red];
				} else {
					fightRedScores[rd_red][userId] = redScores[rd_red];
				}
			}
			for(var rd_blue in blueScores) {
				let fight_rdb_scores = fightBlueScores[rd_blue];
				if(typeof fight_rdb_scores === 'undefined') {
					fightBlueScores[rd_blue] = {};
					fightBlueScores[rd_blue][userId] = blueScores[rd_blue];
				} else {
					fightBlueScores[rd_blue][userId] = blueScores[rd_blue];
				}
			}
		}
		
		let transaction = db.runTransaction(t => {
			return t.get(snapshot.ref).then(_doc => {
				t.update(_doc.ref, {'red_scores': fightRedScores, 'blue_scores': fightBlueScores});
				return;
			});
					
		});
		return 1;
	});
	
});
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
