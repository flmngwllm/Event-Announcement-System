
document.getElementById('eventForm').addEventListener('submit', function(e) {
    e.preventDefault();
})

const eventName = document.getElementById('eventName').value
const eventDate = document.getElementById('eventDate').value
const eventId = document.getElementById('eventId').value

const data = {
    id: eventId,
    name: eventName,
    date: eventDate

}


fetch('url', {
    method: 'PUT',
    headers: {
        'Content-Type': 'application/json'
    },
    body: JSON.stringify(data)
}).then(response => {
    if (!response.ok){
        throw new Error(`Http error: status: ${response.status}`);
    }
    return response.json();
}).then(data =>  {
    console.log('Updated data:', data);
}).catch(error =>{
    console.error('Fetch error:', error);
})
