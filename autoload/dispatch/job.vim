" dispatch.vim job strategy

if exists('g:autoloaded_dispatch_job')
  finish
endif
let g:autoloaded_dispatch_job = 1

if !exists('s:waiting')
  let s:waiting = {}
endif

function! dispatch#job#handle(request) abort
  if !has('job') || a:request.action !=# 'make'
    return 0
  endif
  let job = job_start(a:request.expanded, {
        \ 'out_io': 'file',
        \ 'out_name': a:request.file,
        \ 'err_io': 'out',
        \ 'exit_cb': function('s:exit'),
        \ })
  let pid = job_info(job).process
  let s:waiting[pid] = a:request
  call writefile([pid], a:request.file . '.pid')
  return 1
endfunction

function! s:exit(job, status) abort
  let pid = job_info(a:job).process
  let request = s:waiting[pid]
  call writefile([a:status], request.file . '.complete')
  unlet! s:waiting[pid]
  call dispatch#complete(request.id)
endfunction

function! dispatch#job#activate(pid) abort
  return 0
endfunction
