webpush = require 'web-push'
webpush.setGCMAPIKey Meteor.settings.gcm
webpush.setVapidDetails(
  'mailto:wesley@fundmylife.co',
  Meteor.settings.public.vapid.publicKey,
  Meteor.settings.vapid.privateKey
)



Meteor.methods
    sendPushNotification: () ->
        console.log "sending notification now"
        creds = Collections.Credientials.findOne 'createdBy': Meteor.userId()
        console.log creds
        pushSubscription =
            endpoint: creds.endpoint
            keys:
                auth: creds.auth
                p256dh:creds.p256dh
        webpush.sendNotification(pushSubscription, 'Your Push Payload Text');


    sendSub: (sub) ->
        console.log sub
        sub2 = JSON.parse(sub)
        Collections.Credientials.insert
            endpoint: sub2.endpoint
            p256dh: sub2.keys.p256dh
            auth: sub2.keys.auth
            createdBy: Meteor.userId()

