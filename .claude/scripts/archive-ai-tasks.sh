#!/bin/bash
# TaskMan 2.0 Migration: Move AI tasks to archive project
# Created: 2025-11-10

ARCHIVE_PROJECT_ID=17
TASK_IDS=(211 212 213 214 215 216 217 218 219 260 261 262 263 264 265 267 268 269 270 271 272 273 282 283 284 285 286 287 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383 384 385 386 387 388 389 390 391 392 393 394 396 397 398 399 400 401 402 403 404 405 406 407 408 409 411 412 413 414 415 417 418 419 420 421 422 423 427 428 429 430 431 432 433 434 435 436 437 438 439 440)

echo "TaskMan 2.0 Migration: Moving ${#TASK_IDS[@]} tasks to Archive"
echo "Archive Project ID: $ARCHIVE_PROJECT_ID"
echo "Start time: $(date)"
echo ""

moved_count=0
error_count=0

for task_id in "${TASK_IDS[@]}"; do
    # Use Vikunja API to move task
    response=$(curl -s -X PUT \
        -H "Authorization: Bearer $(grep VIKUNJA_API_TOKEN ~/.env | cut -d '=' -f2)" \
        -H "Content-Type: application/json" \
        -d "{\"project_id\": $ARCHIVE_PROJECT_ID}" \
        "$(grep VIKUNJA_URL ~/.env | cut -d '=' -f2)/api/v1/tasks/$task_id")

    if echo "$response" | grep -q "\"id\":$task_id"; then
        ((moved_count++))
        if [ $((moved_count % 10)) -eq 0 ]; then
            echo "Moved $moved_count tasks..."
        fi
    else
        ((error_count++))
        echo "ERROR moving task $task_id"
    fi
done

echo ""
echo "Migration complete!"
echo "Successfully moved: $moved_count tasks"
echo "Errors: $error_count"
echo "End time: $(date)"
