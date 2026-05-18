const API = 'http://localhost:3000';
let token = localStorage.getItem('skycheck_token');
let adminUser = JSON.parse(localStorage.getItem('skycheck_user')||'{}');
let allNews=[], allUsers=[], allZones=[], allCourses=[];
let adminMap, drawingManager, currentPolygon=null, editingZoneId=null, activeCourseId=null;
let mapsReady=false;

// ── INIT ──
window.onMapsReady = () => { mapsReady=true; if(document.getElementById('section-map').classList.contains('active')) initAdminMap(); };

document.addEventListener('DOMContentLoaded', () => {
  if (token && adminUser.role==='admin') showAdminApp();
  else document.getElementById('admin-login').style.display='flex';
  document.getElementById('admin-email').addEventListener('keydown', e=>e.key==='Enter'&&adminLogin());
  document.getElementById('admin-pass').addEventListener('keydown', e=>e.key==='Enter'&&adminLogin());
});

// ── AUTH ──
async function adminLogin() {
  const email=document.getElementById('admin-email').value.trim();
  const pass=document.getElementById('admin-pass').value;
  if(!email||!pass) return showLoginErr('Заполните все поля');
  try {
    const r=await fetch(`${API}/auth/login`,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({email,password:pass})});
    const d=await r.json();
    if(!r.ok) return showLoginErr(d.error);
    if(d.user.role!=='admin') return showLoginErr('Нет доступа администратора');
    token=d.token; adminUser=d.user;
    localStorage.setItem('skycheck_token',token);
    localStorage.setItem('skycheck_user',JSON.stringify(d.user));
    showAdminApp();
  } catch { showLoginErr('Ошибка соединения'); }
}

function showLoginErr(msg) {
  document.getElementById('admin-login-alert').innerHTML=`<div class="alert alert-error">${msg}</div>`;
}

function showAdminApp() {
  document.getElementById('admin-login').style.display='none';
  document.getElementById('admin-app').style.display='flex';
  const n=adminUser.name||adminUser.email||'Admin';
  document.getElementById('admin-name').textContent=n;
  document.getElementById('admin-avatar').textContent=n[0].toUpperCase();
  loadStats(); loadNews(); loadUsers(); loadCourses(); loadZones();
}

function adminLogout() {
  localStorage.removeItem('skycheck_token');
  localStorage.removeItem('skycheck_user');
  location.reload();
}

// ── NAVIGATION ──
function showSection(name) {
  document.querySelectorAll('.admin-section').forEach(s=>s.classList.remove('active'));
  document.querySelectorAll('.sidebar-item').forEach(b=>b.classList.remove('active'));
  document.getElementById('section-'+name).classList.add('active');
  document.getElementById('nav-'+name).classList.add('active');
  const titles={dashboard:'Dashboard',news:'Новости',map:'Карта зон',users:'Пользователи',courses:'Курсы'};
  document.getElementById('topbar-title').textContent=titles[name]||name;
  if(name==='map'&&mapsReady&&!adminMap) initAdminMap();
}

// ── API HELPERS ──
const authH = () => ({'Content-Type':'application/json','Authorization':'Bearer '+token});
const api = async(url,opt={})=>{
  const r=await fetch(API+url,{...opt,headers:authH()});
  return r.json();
};

// ── STATS ──
async function loadStats() {
  try {
    const d=await api('/admin/stats');
    document.getElementById('s-users').textContent=d.users||0;
    document.getElementById('s-news').textContent=d.news||0;
    document.getElementById('s-courses').textContent=d.courses||0;
    document.getElementById('s-zones').textContent=d.zones||0;
  } catch{}
}

// ── UTILS ──
const esc=s=>String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
const fmtDate=d=>d?new Date(d).toLocaleDateString('ru-RU',{day:'numeric',month:'short',year:'numeric'}):'';
const courseEmoji=t=>({beginner:'🚀',intermediate:'🎯',advanced:'⚡',pro:'🏆'}[t]||'📚');

// ════════════════════════════════════
// NEWS
// ════════════════════════════════════
async function loadNews() {
  try { allNews=await api('/news'); renderNewsTable(); } catch{}
}

function renderNewsTable() {
  const q=(document.getElementById('news-search').value||'').toLowerCase();
  const items=allNews.filter(n=>n.title.toLowerCase().includes(q)||n.author?.toLowerCase().includes(q));
  if(!items.length){
    document.getElementById('news-table-body').innerHTML='<div class="empty-state"><div class="empty-state-icon">📰</div><p>Нет новостей</p></div>';
    return;
  }
  document.getElementById('news-table-body').innerHTML=`
    <table><thead><tr><th>Заголовок</th><th>Автор</th><th>Дата</th><th>Действия</th></tr></thead>
    <tbody>${items.map(n=>`
      <tr>
        <td><strong>${esc(n.title)}</strong></td>
        <td style="color:var(--text-muted)">${esc(n.author||'—')}</td>
        <td style="color:var(--text-muted)">${fmtDate(n.publishedAt)}</td>
        <td style="display:flex;gap:6px">
          <button class="btn btn-secondary btn-sm" onclick="openNewsModal(${n.id})">✏ Изм.</button>
          <button class="btn btn-danger btn-sm" onclick="deleteNews(${n.id})">🗑</button>
        </td>
      </tr>`).join('')}
    </tbody></table>`;
}

function filterNews(){ renderNewsTable(); }

function openNewsModal(id=null) {
  const n=id?allNews.find(x=>x.id===id):null;
  document.getElementById('news-modal-title').textContent=n?'Редактировать новость':'Добавить новость';
  document.getElementById('nm-id').value=n?.id||'';
  document.getElementById('nm-title').value=n?.title||'';
  document.getElementById('nm-author').value=n?.author||'';
  document.getElementById('nm-image').value=n?.imageUrl||'';
  document.getElementById('nm-content').value=n?.content||'';
  document.getElementById('news-modal-alert').innerHTML='';
  document.getElementById('news-modal').style.display='flex';
}
function closeNewsModal(){ document.getElementById('news-modal').style.display='none'; }

async function saveNews() {
  const id=document.getElementById('nm-id').value;
  const body={title:document.getElementById('nm-title').value.trim(),author:document.getElementById('nm-author').value.trim(),imageUrl:document.getElementById('nm-image').value.trim(),content:document.getElementById('nm-content').value.trim()};
  if(!body.title||!body.content) return showModalAlert('news-modal-alert','Заголовок и содержание обязательны');
  try {
    if(id) await api(`/news/${id}`,{method:'PUT',body:JSON.stringify(body)});
    else await api('/news',{method:'POST',body:JSON.stringify(body)});
    closeNewsModal(); loadNews(); loadStats();
  } catch(e){ showModalAlert('news-modal-alert','Ошибка: '+e.message); }
}

async function deleteNews(id) {
  if(!confirm('Удалить эту новость?')) return;
  await api(`/news/${id}`,{method:'DELETE'});
  loadNews(); loadStats();
}

// ════════════════════════════════════
// USERS
// ════════════════════════════════════
async function loadUsers() {
  try { allUsers=await api('/admin/users'); renderUsersTable(); } catch{}
}

function renderUsersTable() {
  const q=(document.getElementById('users-search').value||'').toLowerCase();
  const items=allUsers.filter(u=>u.name.toLowerCase().includes(q)||u.email.toLowerCase().includes(q));
  if(!items.length){
    document.getElementById('users-table-body').innerHTML='<div class="empty-state"><div class="empty-state-icon">👥</div><p>Нет пользователей</p></div>';
    return;
  }
  document.getElementById('users-table-body').innerHTML=`
    <table><thead><tr><th>Имя</th><th>Email</th><th>Роль</th><th>Дата</th><th>Действия</th></tr></thead>
    <tbody>${items.map(u=>`
      <tr>
        <td><strong>${esc(u.name)}</strong></td>
        <td style="color:var(--text-muted)">${esc(u.email)}</td>
        <td><span class="badge badge-${u.role}">${u.role}</span></td>
        <td style="color:var(--text-muted)">${fmtDate(u.createdAt)}</td>
        <td style="display:flex;gap:6px">
          <button class="btn btn-success btn-sm" onclick="toggleRole(${u.id},'${u.role}')">${u.role==='admin'?'→ user':'→ admin'}</button>
          <button class="btn btn-danger btn-sm" onclick="deleteUser(${u.id})">🗑</button>
        </td>
      </tr>`).join('')}
    </tbody></table>`;
}
function filterUsers(){ renderUsersTable(); }

async function toggleRole(id, current) {
  const role=current==='admin'?'user':'admin';
  if(!confirm(`Изменить роль на ${role}?`)) return;
  await api(`/admin/users/${id}/role`,{method:'PUT',body:JSON.stringify({role})});
  loadUsers();
}
async function deleteUser(id) {
  if(!confirm('Удалить пользователя?')) return;
  await api(`/admin/users/${id}`,{method:'DELETE'});
  loadUsers(); loadStats();
}

// ════════════════════════════════════
// MAP ZONES
// ════════════════════════════════════
async function loadZones() {
  try { allZones=await api('/zones'); renderZoneList(); } catch{}
}

function initAdminMap() {
  adminMap=new google.maps.Map(document.getElementById('admin-map'),{
    center:{lat:41.3111,lng:69.2406},zoom:12,
    mapTypeId:'roadmap',
    styles:[{elementType:'geometry',stylers:[{color:'#1e2a3a'}]},{elementType:'labels.text.stroke',stylers:[{color:'#0f172a'}]},{elementType:'labels.text.fill',stylers:[{color:'#8898aa'}]},{featureType:'water',elementType:'geometry',stylers:[{color:'#0f2030'}]}]
  });
  drawingManager=new google.maps.drawing.DrawingManager({
    drawingMode:null,
    drawingControl:false,
    polygonOptions:{strokeWeight:2,fillOpacity:0.3,editable:true}
  });
  drawingManager.setMap(adminMap);
  google.maps.event.addListener(drawingManager,'polygoncomplete',onPolygonComplete);
  allZones.forEach(z=>drawAdminZone(z));
}

function drawAdminZone(zone) {
  const colors={RED:'#EF4444',YELLOW:'#F59E0B',GREEN:'#10B981'};
  const color=colors[zone.type]||'#6B7280';
  let coords=zone.coordinates;
  if(typeof coords==='string') try{coords=JSON.parse(coords);}catch{}
  if(!Array.isArray(coords)) return;
  const paths=coords.map(p=>Array.isArray(p)?{lat:p[1],lng:p[0]}:{lat:p.lat,lng:p.lng});
  const poly=new google.maps.Polygon({paths,strokeColor:color,strokeWeight:2,fillColor:color,fillOpacity:0.25,map:adminMap});
  poly.addListener('click',()=>selectZone(zone.id));
  return poly;
}

function onPolygonComplete(poly) {
  currentPolygon=poly; editingZoneId=null;
  document.getElementById('zone-form-panel').style.display='block';
  document.getElementById('zone-form-title').textContent='Новая зона';
  document.getElementById('zf-name').value='';
  document.getElementById('zf-alt').value='50';
}

function startDrawing() {
  if(!adminMap) return;
  drawingManager.setDrawingMode(google.maps.drawing.OverlayType.POLYGON);
  document.getElementById('draw-btn').textContent='✏ Рисование...';
}
function stopDrawing() {
  if(!drawingManager) return;
  drawingManager.setDrawingMode(null);
  document.getElementById('draw-btn').textContent='✏ Рисовать';
}

function renderZoneList() {
  const colors={RED:'#EF4444',YELLOW:'#F59E0B',GREEN:'#10B981'};
  document.getElementById('zone-list').innerHTML=allZones.length
    ? allZones.map(z=>`
        <div class="zone-list-item" id="zitem-${z.id}" onclick="selectZone(${z.id})">
          <div class="zone-dot" style="background:${colors[z.type]||'#6B7280'}"></div>
          <div class="zone-list-name">${esc(z.name)}</div>
          <span class="badge badge-${z.type?.toLowerCase()}">${z.type}</span>
          <button class="btn btn-danger btn-sm" onclick="event.stopPropagation();deleteZone(${z.id})">🗑</button>
        </div>`).join('')
    : '<div class="empty-state" style="padding:30px"><p>Нет зон. Нарисуйте полигон.</p></div>';
}

function selectZone(id) {
  const z=allZones.find(x=>x.id===id); if(!z) return;
  document.querySelectorAll('.zone-list-item').forEach(el=>el.classList.remove('selected'));
  const el=document.getElementById('zitem-'+id); if(el) el.classList.add('selected');
  editingZoneId=id;
  document.getElementById('zone-form-panel').style.display='block';
  document.getElementById('zone-form-title').textContent='Редактировать зону';
  document.getElementById('zf-name').value=z.name;
  document.getElementById('zf-type').value=z.type;
  document.getElementById('zf-alt').value=z.maxAltitude;
}

async function saveZone() {
  const name=document.getElementById('zf-name').value.trim();
  const type=document.getElementById('zf-type').value;
  const maxAltitude=parseInt(document.getElementById('zf-alt').value)||50;
  if(!name) return alert('Введите название зоны');

  if(editingZoneId) {
    await api(`/zones/${editingZoneId}`,{method:'PUT',body:JSON.stringify({name,type,maxAltitude})});
  } else {
    if(!currentPolygon) return alert('Нарисуйте зону на карте');
    const coords=currentPolygon.getPath().getArray().map(p=>[p.lng(),p.lat()]);
    await api('/zones',{method:'POST',body:JSON.stringify({name,type,coordinates:coords,maxAltitude})});
    currentPolygon.setMap(null); currentPolygon=null;
    stopDrawing();
  }
  cancelZoneForm(); loadZones(); loadStats();
}

async function deleteZone(id) {
  if(!confirm('Удалить зону?')) return;
  await api(`/zones/${id}`,{method:'DELETE'});
  loadZones(); loadStats();
}

function cancelZoneForm() {
  document.getElementById('zone-form-panel').style.display='none';
  editingZoneId=null;
  if(currentPolygon){currentPolygon.setMap(null);currentPolygon=null;}
}

// ════════════════════════════════════
// COURSES
// ════════════════════════════════════
async function loadCourses() {
  try { allCourses=await api('/courses'); renderAdminCoursesList(); } catch{}
}

function renderAdminCoursesList() {
  const el=document.getElementById('admin-courses-list');
  el.innerHTML=allCourses.length
    ? allCourses.map(c=>`
        <div class="course-list-item ${c.id===activeCourseId?'active':''}" onclick="openAdminCourse(${c.id})">
          <div class="course-list-icon" style="background:${c.color}22">${courseEmoji(c.iconType)}</div>
          <div>
            <div class="course-list-name">${esc(c.title)}</div>
            <div class="course-list-steps">${c.steps?.length||0} шагов</div>
          </div>
        </div>`).join('')
    : '<div class="empty-state" style="padding:30px"><p>Нет курсов</p></div>';
}

function openAdminCourse(id) {
  activeCourseId=id;
  renderAdminCoursesList();
  const c=allCourses.find(x=>x.id===id); if(!c) return;
  const panel=document.getElementById('course-editor-panel');
  panel.innerHTML=`
    <div class="course-editor-header">
      <div>
        <div style="font-weight:700;font-size:1.1rem">${esc(c.title)}</div>
        <div style="color:var(--text-muted);font-size:0.82rem">${esc(c.description)}</div>
      </div>
      <div style="display:flex;gap:8px">
        <button class="btn btn-secondary btn-sm" onclick="openCourseModal(${c.id})">✏ Изм.</button>
        <button class="btn btn-danger btn-sm" onclick="deleteCourse(${c.id})">🗑</button>
      </div>
    </div>
    <div class="steps-editor" id="steps-editor-${c.id}">
      ${renderStepsEditor(c)}
      <button class="btn btn-secondary" style="width:100%;justify-content:center;margin-top:8px" onclick="addStep(${c.id})">+ Добавить шаг</button>
    </div>`;
}

function renderStepsEditor(c) {
  if(!c.steps?.length) return '<div class="empty-state" style="padding:30px"><p>Нет шагов. Добавьте первый.</p></div>';
  return c.steps.map((s,i)=>`
    <div class="step-editor-card" id="step-card-${s.id}">
      <div class="step-editor-top">
        <div style="display:flex;align-items:center;gap:10px">
          <div class="step-num">${i+1}</div>
          <input value="${esc(s.title)}" id="st-title-${s.id}" style="background:var(--bg-card2);border:1px solid var(--border);border-radius:8px;padding:6px 12px;color:var(--text);font-size:0.875rem;width:200px;font-family:inherit;outline:none">
        </div>
        <div style="display:flex;gap:6px">
          <div class="step-type-selector">
            ${['text','video','quiz'].map(t=>`<button class="step-type-btn ${s.type===t?'active':''}" onclick="changeStepType(${s.id},${c.id},'${t}',this)">${{text:'📄',video:'🎬',quiz:'📝'}[t]} ${t}</button>`).join('')}
          </div>
          <button class="btn btn-danger btn-sm" onclick="deleteStep(${s.id},${c.id})">🗑</button>
        </div>
      </div>
      ${renderStepInput(s)}
      <div style="margin-top:12px;text-align:right">
        <button class="btn btn-primary btn-sm" onclick="saveStep(${s.id},${c.id})">💾 Сохранить шаг</button>
      </div>
    </div>`).join('');
}

function renderStepInput(s) {
  if(s.type==='text') return `<textarea id="st-content-${s.id}" rows="5" style="width:100%;background:var(--bg);border:1px solid var(--border);border-radius:10px;padding:12px;color:var(--text);font-family:inherit;font-size:0.875rem;resize:vertical;outline:none" placeholder="Текст урока...">${esc(s.content||'')}</textarea>`;
  if(s.type==='video') return `<input id="st-content-${s.id}" value="${esc(s.content||'')}" placeholder="YouTube URL: https://youtube.com/watch?v=..." style="width:100%;background:var(--bg);border:1px solid var(--border);border-radius:10px;padding:11px 16px;color:var(--text);font-family:inherit;font-size:0.875rem;outline:none">`;
  if(s.type==='quiz') return renderQuizBuilder(s);
  return '';
}

function renderQuizBuilder(s) {
  const qs=s.questions||[{question:'',options:['','','',''],answer:0}];
  return `<div class="quiz-builder" id="quiz-${s.id}">
    ${qs.map((q,qi)=>`
      <div style="background:var(--bg-card2);border-radius:10px;padding:14px;margin-bottom:10px">
        <div style="font-size:0.8rem;color:var(--text-muted);margin-bottom:8px">Вопрос ${qi+1}</div>
        <input id="q-${s.id}-${qi}-q" value="${esc(q.question)}" placeholder="Вопрос..." style="width:100%;background:var(--bg);border:1px solid var(--border);border-radius:8px;padding:8px 12px;color:var(--text);font-family:inherit;font-size:0.875rem;outline:none;margin-bottom:10px">
        ${(q.options||[]).map((opt,oi)=>`
          <div style="display:flex;align-items:center;gap:8px;margin-bottom:6px">
            <input type="radio" name="ans-${s.id}-${qi}" ${oi===q.answer?'checked':''} onchange="document.getElementById('qa-${s.id}-${qi}').value='${oi}'">
            <input id="q-${s.id}-${qi}-o${oi}" value="${esc(opt)}" placeholder="Вариант ${oi+1}" style="flex:1;background:var(--bg);border:1px solid var(--border);border-radius:8px;padding:7px 12px;color:var(--text);font-family:inherit;font-size:0.85rem;outline:none">
          </div>`).join('')}
        <input type="hidden" id="qa-${s.id}-${qi}" value="${q.answer||0}">
      </div>`).join('')}
    <input type="hidden" id="quiz-count-${s.id}" value="${qs.length}">
  </div>`;
}

function changeStepType(stepId, courseId, type, btn) {
  btn.closest('.step-type-selector').querySelectorAll('.step-type-btn').forEach(b=>b.classList.remove('active'));
  btn.classList.add('active');
  const c=allCourses.find(x=>x.id===courseId);
  const s=c?.steps?.find(x=>x.id===stepId);
  if(s){ s.type=type; const card=document.getElementById('step-card-'+stepId); if(card){ const inp=card.querySelector('.quiz-builder, textarea, input[id^="st-content"]'); if(inp) inp.outerHTML=renderStepInput({...s,type}); } }
}

async function saveStep(stepId, courseId) {
  const title=document.getElementById(`st-title-${stepId}`)?.value?.trim();
  const c=allCourses.find(x=>x.id===courseId);
  const s=c?.steps?.find(x=>x.id===stepId);
  if(!s||!title) return;
  const type=s.type;
  let content=null, questions=null;
  if(type!=='quiz') content=document.getElementById(`st-content-${stepId}`)?.value?.trim();
  else {
    const count=parseInt(document.getElementById(`quiz-count-${stepId}`)?.value||'1');
    questions=[];
    for(let qi=0;qi<count;qi++){
      const question=document.getElementById(`q-${stepId}-${qi}-q`)?.value?.trim()||'';
      const answer=parseInt(document.getElementById(`qa-${stepId}-${qi}`)?.value||'0');
      const options=[0,1,2,3].map(oi=>document.getElementById(`q-${stepId}-${qi}-o${oi}`)?.value?.trim()||'');
      questions.push({question,options,answer});
    }
  }
  await api(`/courses/${courseId}/steps/${stepId}`,{method:'PUT',body:JSON.stringify({title,type,content,questions,order:s.order})});
  await loadCourses(); openAdminCourse(courseId);
}

async function addStep(courseId) {
  const c=allCourses.find(x=>x.id===courseId);
  const order=(c?.steps?.length||0)+1;
  await api(`/courses/${courseId}/steps`,{method:'POST',body:JSON.stringify({title:'Новый шаг',type:'text',content:'',order})});
  await loadCourses(); openAdminCourse(courseId);
}

async function deleteStep(stepId, courseId) {
  if(!confirm('Удалить шаг?')) return;
  await api(`/courses/${courseId}/steps/${stepId}`,{method:'DELETE'});
  await loadCourses(); openAdminCourse(courseId);
}

function openCourseModal(id=null) {
  const c=id?allCourses.find(x=>x.id===id):null;
  document.getElementById('cm-title').textContent=c?'Редактировать курс':'Новый курс';
  document.getElementById('cm-id').value=c?.id||'';
  document.getElementById('cm-name').value=c?.title||'';
  document.getElementById('cm-desc').value=c?.description||'';
  document.getElementById('cm-icon').value=c?.iconType||'beginner';
  document.getElementById('cm-color').value=c?.color||'#2563EB';
  document.getElementById('cm-alert').innerHTML='';
  document.getElementById('course-modal').style.display='flex';
}
function closeCourseModal(){ document.getElementById('course-modal').style.display='none'; }

async function saveCourse() {
  const id=document.getElementById('cm-id').value;
  const body={title:document.getElementById('cm-name').value.trim(),description:document.getElementById('cm-desc').value.trim(),iconType:document.getElementById('cm-icon').value,color:document.getElementById('cm-color').value};
  if(!body.title) return showModalAlert('cm-alert','Название обязательно');
  if(id) await api(`/courses/${id}`,{method:'PUT',body:JSON.stringify(body)});
  else await api('/courses',{method:'POST',body:JSON.stringify(body)});
  closeCourseModal(); await loadCourses(); loadStats();
  if(id) openAdminCourse(parseInt(id));
}

async function deleteCourse(id) {
  if(!confirm('Удалить курс и все его шаги?')) return;
  await api(`/courses/${id}`,{method:'DELETE'});
  activeCourseId=null;
  document.getElementById('course-editor-panel').innerHTML='<div style="display:flex;align-items:center;justify-content:center;height:100%;color:var(--text-muted)"><div style="text-align:center"><div style="font-size:3rem;margin-bottom:12px">📚</div><p>Выберите курс слева</p></div></div>';
  await loadCourses(); loadStats();
}

function showModalAlert(elId, msg) {
  document.getElementById(elId).innerHTML=`<div class="alert alert-error">${msg}</div>`;
}
