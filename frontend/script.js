fetch('./config.json')
  .then(response => response.json())
  .then(config => {
    const apiBaseUrl = config.apiBaseUrl;

    // Handle create event form submission
    document.getElementById('eventForm').addEventListener('submit', function(e) {
      e.preventDefault();

      const eventName = document.getElementById('eventName').value;
      const eventDate = document.getElementById('eventDate').value;
      const eventId = document.getElementById('eventId').value;
      const eventButton = doccument.getElementById('eventButton');
      
      if (!eventName || !eventDate || !eventId) {
        eventButton.disabled = true;
      } else {
        eventButton.disabled = false;
      }

      const payload = {
        id: eventId,
        name: eventName,
        date: eventDate
      };

      fetch(`${apiBaseUrl}/new_events`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(payload)
      }).then(response => {
        if (!response.ok) {
          throw new Error(`Http error: status: ${response.status}`);
        }
        return response.json();
      }).then(data => {
        console.log('Event created:', data);

      // Clear input fields after successful creation
        eventName.value = '';
        eventDate.value = '';
        eventId.value = '';

        getEvents(apiBaseUrl); 
      }).catch(error => {
        console.error('Fetch error:', error);
      });
    });

    // Handle subscribe form submission
    document.getElementById('subscriptionForm').addEventListener('submit', function(e) {
      e.preventDefault();

      const email = document.getElementById('email').value;
      const subButton = document.getElementById('subButton');

      if (!email) {
        subButton.disabled = true;
      } else {
        subButton.disabled = false;
      }

      fetch(`${apiBaseUrl}/subscribe`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ email })
      }).then(response => {
        if (!response.ok) {
          throw new Error(`Http error: status: ${response.status}`);
        }
        return response.json();
      }).then(data => {
        console.log('Subscription successful:', data);
        email.value = '';
      }).catch(error => {
        console.error('Fetch error:', error);
      });
    });

  // Initial call to get events
    getEvents(apiBaseUrl);
  })
  .catch(error => {
    console.error('Failed to load config.json:', error);
  });

//Get events function with apiBaseUrl as parameter
function getEvents(apiBaseUrl) {
  fetch(`${apiBaseUrl}/events`, {
    method: 'GET'
  }).then(response => {
    if (!response.ok) {
      throw new Error(`Http error: status: ${response.status}`);
    }
    return response.json();
  }).then(data => {
    const list = document.getElementById('eventsList');
    list.innerHTML = '';
    data.forEach(event => {
      const item = document.createElement('li');
      item.textContent = `${event.name} - ${event.date}`;
      list.appendChild(item);
    });
  }).catch(error => {
    console.error('Fetch error:', error);
  });
}