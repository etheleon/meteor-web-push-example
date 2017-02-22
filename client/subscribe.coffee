#https://developers.google.com/web/fundamentals/getting-started/codelabs/push-notifications/
applicationServerPublicKey = Meteor.settings.public.vapid.publicKey
swRegistration = null
isSubscribed = false

urlB64ToUint8Array= (base64String) ->
  padding = '='.repeat((4 - (base64String.length % 4)) % 4)
  base64 = (base64String + padding).replace(/\-/g, '+').replace(/_/g, '/')
  rawData = window.atob(base64)
  outputArray = new Uint8Array(rawData.length)
  i = 0
  while i < rawData.length
    outputArray[i] = rawData.charCodeAt(i)
    ++i
  outputArray

#functions
updateBtn = (pushButton)->
  #pushButton = document.querySelector('#push')
  if isSubscribed
    console.log pushButton
    pushButton.textContent = 'Disable Push Messaging'
  else
    console.log pushButton
    pushButton.textContent = 'Enable Push Messaging'
  pushButton.disabled = false
  return

subscribeUser = ->
  applicationServerKey = urlB64ToUint8Array(applicationServerPublicKey)
  swRegistration.pushManager.subscribe(
    userVisibleOnly: true
    applicationServerKey: applicationServerKey).then((subscription) ->
    console.log 'User is subscribed.'
    updateSubscriptionOnServer subscription
    isSubscribed = true
    updateBtn(document.querySelector('#push'))
    return
  ).catch (err) ->
    console.log 'Failed to subscribe the user: ', err
    updateBtn(document.querySelector('#push'))
    return
  return

unsubscribeUser = ->
  swRegistration.pushManager.getSubscription().then((subscription) ->
    if subscription
      return subscription.unsubscribe()
    return
  ).catch((error) ->
    console.log 'Error unsubscribing', error
    return
  ).then ->
    updateSubscriptionOnServer null
    console.log 'User is unsubscribed.'
    isSubscribed = false
    updateBtn(document.querySelector('#push'))
    return
  return

updateSubscriptionOnServer = (subscription) ->
  # TODO: Send subscription to application server
  subscriptionJson = document.querySelector('.js-subscription-json')
  subscriptionDetails = document.querySelector('.js-subscription-details')
  if subscription
    subscriptionJson.textContent = JSON.stringify(subscription)
    subscriptionDetails.classList.remove 'is-invisible'
    Meteor.call 'sendSub', JSON.stringify(subscription)
  else
    subscriptionDetails.classList.add 'is-invisible'
  return


Template.hello.events
    'click #push': ->
      console.log 'hello world'
      if isSubscribed
        unsubscribeUser()
      else
        subscribeUser()

    'click #notification' : ->
        Meteor.call 'sendPushNotification'

Template.hello.onCreated ->
  #console.log applicationServerPublicKey

  initialiseUI = ->
    # Set the initial subscription value
    swRegistration.pushManager.getSubscription().then (subscription) ->
      isSubscribed = !(subscription == null)
      if isSubscribed
        console.log 'User IS subscribed.'
      else
        console.log 'User is NOT subscribed.'
      updateBtn(document.querySelector('#push'))
      return
    return


  if 'serviceWorker' of navigator and 'PushManager' of window
    console.log 'Service Worker and Push is supported'
    navigator.serviceWorker.register('sw.js').then((swReg) ->
      console.log 'Service Worker is registered', swReg
      swRegistration = swReg
      return
    ).catch (error) ->
      console.error 'Service Worker Error', error
      return
  else
    console.warn 'Push messaging is not supported'
    pushButton.textContent = 'Push Not Supported'

  navigator.serviceWorker.register('sw.js').then (swReg) ->
    console.log 'Service Worker is registered', swReg
    swRegistration = swReg
    initialiseUI()
    return



