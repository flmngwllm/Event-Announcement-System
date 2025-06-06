
document.getElementById('eventForm').addEventListener('submit', function(e) {
    e.preventDefault();

// Create Event Funtion to handle event form submission
const eventName = document.getElementById('eventName').value
const eventDate = document.getElementById('eventDate').value
const eventId = document.getElementById('eventId').value

const payload = {
    id: eventId,
    name: eventName,
    date: eventDate

}


fetch('url', {
    method: 'PUT',
    headers: {
        'Content-Type': 'application/json'
    },
    body: JSON.stringify(payload)
}).then(response => {
    if (!response.ok){
        throw new Error(`Http error: status: ${response.status}`);
    }
    return response.json();
}).then(data =>  {
    console.log('Event created:', data);
    getEvents()
}).catch(error =>{
    console.error('Fetch error:', error);
})

})


// Function to handle subscibe form submission

document.getElementById('subscriptionForm').addEventListener('submit', function(e){
    e.preventDefault()


const email = document.getElementById('email').value

fetch('url', {
    method: 'PUT',
    headers: {
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({email})
}).then(response => {
    if (!response.ok){
        throw new Error(`Http error: status: ${response.status}`);
    }
    return response.json()
}).then(data => {
    console.log('Subscription successful:', data);
}).catch(error =>{
    console.error('Fetch error:', error);    
})
})


// function to Get List of events
function getEvents(){
    fetch('url',{
        method: 'GET',

    }).then(response => {
    if (!response.ok){
        throw new Error(`Http error: status: ${response.status}`)
    }
    return response.json()
    
}).then(data =>{
    list = document.getElementById('eventList')
    list.innerHTML = '';
    data.forEach(event =>{
        const item = document.createElement('li');
        item.textContent = `${event.name} - ${event.date}`;
        list.appendChild(item);
    })
}).catch(error => {
    console.error('Fetch error:', error)
})

}


document.addEventListener('DOMContentLoaded', getEvents);