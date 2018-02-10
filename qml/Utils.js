
function openFile(path) {
    var xhr = new XMLHttpRequest()

    xhr.open('GET', path, false)
    xhr.send(null)

    if (xhr.status === 200) {
        return xhr.responseText
    }

    return ""
}
