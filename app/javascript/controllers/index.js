import { application } from "./application"
import PasskeyController from "./passkey_controller"
import TagSelectorController from "./tag_selector_controller"
import TodoFormController from "./todo_form_controller"
import TodoToggleController from "./todo_toggle_controller"
import WeekNavController from "./week_nav_controller"

application.register("passkey", PasskeyController)
application.register("tag-selector", TagSelectorController)
application.register("todo-form", TodoFormController)
application.register("todo-toggle", TodoToggleController)
application.register("week-nav", WeekNavController)
