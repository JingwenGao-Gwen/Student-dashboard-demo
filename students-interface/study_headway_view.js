(function (root) {
  'use strict';
  root.renderUpdatedStudyHeadway = function (el, ctx) {
    const {programme, year, records, selections, onSelection, isPassing, esc, courseLink, progressBlock} = ctx;
    const engine = root.StudyHeadwayEngine;
    const variant = engine.variantFor(programme, year);
    if (!variant) { el.innerHTML = `<p>No verified study scheme for ${esc(programme.label)}, ${esc(year)} entry. Select a supported admission year; another cohort's rules are not substituted.</p>`; return; }
    const stateKey = `${ctx.major}:${variant.id}`;
    const state = selections[stateKey] || {};
    const path = variant.paths.length === 1 ? variant.paths[0] : variant.paths.find(p => p.id === state.path);
    let header = '';
    if (variant.paths.length > 1) header += `<label>Required stream / concentration <select id="headway-path"><option value="">Select your stream</option>${variant.paths.map(p => `<option value="${esc(p.id)}" ${p === path ? 'selected' : ''}>${esc(p.label)}</option>`).join('')}</select></label>`;
    const source = `<details><summary>Study scheme source</summary><p>${esc(variant.source.file)} · pp. ${variant.source.pages.join(', ')}<br>${esc(variant.source.applicability)}</p></details>`;
    if (!path) {
      el.innerHTML = header + '<p>Select a stream to calculate major progress. No stream is assumed.</p>' + source;
    } else {
      const {earned, unknown} = engine.earnedRecords(records, variant.courseUnits, isPassing);
      const result = engine.evaluate(variant, path, earned, state.declaration);
      const groupLabel = g => g.options.map(a => a.map(courseLink).join(' + ')).join(' OR ');
      const components = result.components.map(c => `<details ${c.complete ? '' : 'open'}><summary>${esc(c.label)}: ${c.units}/${c.minUnits} units · ${c.complete ? 'Satisfied' : 'Incomplete'}</summary>${c.groups.filter(g => !g.complete).map(g => `<div>${groupLabel(g.group)}</div>`).join('')}${c.groups.every(g => g.complete) && !c.complete ? '<p>Course choices met, but earned units are below the printed minimum.</p>' : ''}</details>`).join('');
      const poolHtml = result.pools.map(p => `<details><summary>${esc(p.label)}: ${p.units} units${p.minUnits ? ' / minimum ' + p.minUnits : ''}; ${p.count} courses${p.minCourses ? ' / minimum ' + p.minCourses : ''}</summary><div>${p.groups.map(groupLabel).join(' · ')}</div></details>`).join('');
      const checkLabels = {course_count: 'Elective course count', breadth: 'Categories covered (complementary electives are one eligible category)', depth: 'Courses in one eligible area / stream'};
      const checks = result.checks.map(c => `<p>${c.complete ? '✓' : '✕'} ${checkLabels[c.type]}: ${c.value}/${c.min}</p>`).join('');
      const limits = path.constraints.filter(c => c.type === 'max_level_count').map(c => `<p>At most ${c.max} elective courses at levels ${c.atLeast}–${c.below - 1} count.${result.excluded.length ? ' Not counted: ' + result.excluded.map(x => esc(x.code)).join(', ') : ''}</p>`).join('');
      const issues = path.issues.map(i => `<p role="note">${i.blocking ? 'Rule needs confirmation: ' : 'Source note: '}${esc(i.message)}</p>`).join('');
      let declaration = '';
      if (path.optionalStreams?.length) {
        declaration = `<label>Optional stream declaration <select id="headway-declaration"><option value="">No declaration</option>${path.optionalStreams.map(s => `<option value="${esc(s.id)}" ${result.declaration?.id === s.id ? 'selected' : ''}>${esc(s.label)}</option>`).join('')}</select></label>`;
        if (result.declaration) declaration += `<p>Declaration ${result.declaration.complete ? 'requirements satisfied' : 'incomplete'}: ${result.declaration.requirements.map(r => `${r.count}/${r.min} courses`).join('; ')}. ${esc(result.declaration.notice || '')}</p>`;
      }
      const notes = (path.externalElectiveMaxUnits ? `<p>Up to ${path.externalElectiveMaxUnits} units of other appropriate electives require programme approval. They are not automatically inferred from course prefixes.</p>` : '') + (path.restrictedElectivesNotice ? `<p>${esc(path.restrictedElectivesNotice)}</p>` : '');
      const totalUnits = [...earned.values()].reduce((a, b) => a + b, 0);
      const body = `<p><strong>${result.blocking.length ? 'Rule needs confirmation' : result.complete ? 'Major requirements satisfied' : 'Major requirements incomplete'}</strong></p>${issues}${components}<p>Major electives: ${result.electiveUnits}/${path.electiveUnits} units</p>${poolHtml}${checks}${limits}${declaration}${notes}${source}<details><summary>Scheme notes</summary><p style="white-space:pre-line">${esc(path.notes)}</p></details>`;
      const creditBody = '<p>Passed course records only; planned courses in the basket do not count. Repeated course codes count once. This credit total alone does not certify graduation.</p>' + (unknown.length ? `<p>Missing credit values — excluded pending confirmation: ${unknown.map(esc).join(', ')}.</p>` : '');
      el.innerHTML = header + progressBlock('Credit Progress', Math.min(120, totalUnits), 120, creditBody) + progressBlock('Major Progress', result.done, result.total, body) + ctx.ucoreHtml(earned, programme);
    }
    const pathSelect = el.querySelector('#headway-path');
    if (pathSelect) pathSelect.addEventListener('change', () => onSelection(stateKey, {path: pathSelect.value, declaration: ''}));
    const declSelect = el.querySelector('#headway-declaration');
    if (declSelect) declSelect.addEventListener('change', () => onSelection(stateKey, {...state, declaration: declSelect.value}));
    ctx.resize();
  };
})(window);
