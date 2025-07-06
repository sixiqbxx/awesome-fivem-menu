const options = [
  { label: 'Refill Fuel', action: 'refuel' },
  { label: 'Repair Vehicle', action: 'repair' },
  { label: 'Unlock Vehicle', action: 'unlock' },
  { label: 'Auto Fish 1', action: 'fish1' },
  { label: 'Auto Fish 2', action: 'fish2' },
  { label: 'Stop Fishing', action: 'stop_fish' },
  { label: 'Kill Player', action: 'kill' },
];

let selected = 0;
const menu = document.getElementById('menu');
const ul = document.getElementById('options');

// Build menu
options.forEach((opt, i) => {
  const li = document.createElement('li');
  li.textContent = opt.label;
  li.dataset.action = opt.action;
  if (i === selected) li.classList.add('active');
  li.addEventListener('click', () => select(i));
  ul.appendChild(li);
});

function select(i) {
  ul.children[selected]?.classList.remove('active');
  selected = i;
  ul.children[selected]?.classList.add('active');
}

function trigger() {
  fetch(`https://${GetParentResourceName()}/onOption`, {
    method: 'POST',
    body: JSON.stringify({ action: options[selected].action })
  });
}

window.addEventListener('message', e => {
  if (e.data.type === 'toggleMenu') {
    menu.classList.toggle('hidden');
  }
});

window.addEventListener('keydown', e => {
  if (e.key === 'ArrowUp') select((selected + options.length - 1) % options.length);
  if (e.key === 'ArrowDown') select((selected + 1) % options.length);
  if (e.key === 'Enter') trigger();
});
