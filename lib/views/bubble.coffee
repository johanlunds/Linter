{Range} = require 'atom'
Message = require './message'

class Bubble
  constructor: (@linter) ->
    @bubble = null
  render: (message) ->
    root = document.createElement 'div'
    root.id = 'linter-inline'
    MessageLine = new Message()
    MessageLine.initialize(message, false)
    root.appendChild MessageLine
    if message.trace and message.trace.length
      message.trace.forEach (trace) ->
        MessageLine = new Message()
        MessageLine.initialize(trace, true)
        root.appendChild MessageLine
    root

  update: (point) ->
    @remove()
    return unless @linter.views.messages.length
    textEditor = @linter.activeEditor
    found = false
    @linter.views.messages.forEach (message) =>
      return if found
      return unless message.currentFile
      return unless message.position
      p = message.position
      errorRange = new Range([p[0][0] - 1, p[0][1] - 1], [p[1][0] - 1, p[1][1]])
      return unless errorRange.containsPoint point
      marker = textEditor.markBufferRange errorRange, {invalidate: 'never'}
      @bubble = textEditor.decorateMarker(marker, {
        type: 'overlay',
        position: 'tail',
        item: @render(message)
      })
      found = true
  remove: ->
    @bubble?.destroy()

module.exports = Bubble